#!/bin/bash
set -e

# --- 1) Install system packages ---
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  python3 python3-pip python3-flask nginx

# --- 2) Create appuser & working dir ---
useradd -m -s /bin/bash appuser
WORK_DIR=/home/appuser
chown -R appuser:appuser $WORK_DIR

# --- 3) Write Flask apps ---

# App on port 7777
cat > $WORK_DIR/app1.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello1():
    return "Hello — you hit port 7777!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7777)
EOF

# App on port 6666
cat > $WORK_DIR/app2.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello2():
    return "Greetings — you reached port 6666!--karthik from the DevOps team!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6666)
EOF

chown appuser:appuser $WORK_DIR/app1.py $WORK_DIR/app2.py

# --- 4) systemd services for Flask apps ---

cat > /etc/systemd/system/app1.service << 'EOF'
[Unit]
Description=Flask App on Port 7777
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser
ExecStart=/usr/bin/python3 /home/appuser/app1.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/app2.service << 'EOF'
[Unit]
Description=Flask App on Port 6666
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser
ExecStart=/usr/bin/python3 /home/appuser/app2.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable & start both
systemctl daemon-reload
systemctl enable app1.service app2.service
systemctl start  app1.service app2.service

# --- 5) Configure Nginx as reverse proxy ---

# Remove default site to avoid conflicts
rm -f /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/flask-proxy << 'EOF'
server {
    listen 80 default_server;
    server_name _;

    # /path1 → Flask on 7777
    location /path1/ {
        proxy_pass         http://127.0.0.1:7777/;
        proxy_http_version 1.1;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }

    # /path2 → Flask on 6666
    location /path2/ {
        proxy_pass         http://127.0.0.1:6666/;
        proxy_http_version 1.1;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }

    # fallback
    location / {
        return 404 "Not Found\n";
    }
}
EOF

ln -s /etc/nginx/sites-available/flask-proxy /etc/nginx/sites-enabled/flask-proxy

# Test & reload Nginx
nginx -t
systemctl reload nginx
