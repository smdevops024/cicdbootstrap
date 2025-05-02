#!/bin/bash
echo "[INFO] Updating cicd-bootstrap.sh..."
curl -s -o "$HOME/bin/cicd-bootstrap.sh" https://your-server.com/path/to/cicd-bootstrap-v1.0.7.sh
chmod +x "$HOME/bin/cicd-bootstrap.sh"
echo "[SUCCESS] Updated to v2.6"
