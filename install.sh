#!/bin/bash
echo "[INFO] Installing cicd-bootstrap.sh to ~/bin..."

mkdir -p "$HOME/bin"
cp cicd-bootstrap.sh "$HOME/bin/cicd-bootstrap.sh"
chmod +x "$HOME/bin/cicd-bootstrap.sh"

# Add to PATH if not already
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

if ! grep -q 'alias cicd=' "$HOME/.bashrc"; then
  echo 'alias cicd="cicd-bootstrap.sh"' >> "$HOME/.bashrc"
fi

echo "[SUCCESS] Installed. Run 'source ~/.bashrc' and then use 'cicd'"
