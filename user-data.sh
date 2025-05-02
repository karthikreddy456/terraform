#!/bin/bash
set -e

# 1) Update OS and install Python3 + pip
apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip

# 2) Install Flask

sudo apt-get install -y python3-flask

# 3) Create app user and working directory
useradd -m -s /bin/bash appuser
WORK_DIR=/home/appuser
chown -R appuser:appuser $WORK_DIR

# 4) Write the Flask “Hello World” app
cat > $WORK_DIR/app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello World"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7777)
EOF
chown appuser:appuser $WORK_DIR/app.py

# 5) Define a systemd service so it starts on boot and restarts on failure
cat > /etc/systemd/system/hello.service << 'EOF'
[Unit]
Description=Hello World Flask App
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser
ExecStart=/usr/bin/python3 /home/appuser/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 6) Enable & start the service
systemctl daemon-reload
systemctl enable hello.service
systemctl start hello.service
