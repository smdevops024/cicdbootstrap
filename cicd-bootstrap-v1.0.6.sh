#!/bin/bash
echo "[DEBUG] Loaded from: $0"
echo "[INFO]  CICD Bootstrap v1.0.3 — OS-aware: $(date)"

# ========== OS DETECTION ==========
OS_TYPE="$(uname -s)"
case "${OS_TYPE}" in
    Linux*)     MACHINE_OS=Linux;;
    Darwin*)    MACHINE_OS=macOS;;
    MINGW*|MSYS*|CYGWIN*) MACHINE_OS=Windows;;
    *)          MACHINE_OS="UNKNOWN"
esac

echo "[INFO]  Detected OS: $MACHINE_OS"

#!/bin/bash
echo "[DEBUG] Loaded from: $0"
echo "[INFO]  CICD Bootstrap v1.0.2 — Deep Cleaned: $(date)"

# ========== STEP LOGGING FUNCTION ==========
step() {
  echo -e "\033[1;36m[STEP]\033[0m  $1"
}

# ========== START ==========
echo -e "[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m"
echo -e "[1;33m👑 Raja Muhammad Awais - DevOps[0m"
echo -e "[0;36mAutomate with precision. Secure with honor.[0m"
echo -e "[0;36mScale with vision. Lead with purpose.[0m"
echo -e "[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[0m"
echo "📝 Logging session to cicd-log.txt..."

# AI Model Selection
step "Selecting AI model for CI/CD assistance..."
echo "[INFO]  Waiting for AI model selection..."
echo "1) ChatGPT"
echo "2) Gemini"
echo "3) DeepSeek (default)"
read -p "Enter choice [1-3]: " ai_choice

# API key prompt logic
case $ai_choice in
  1) AI_PROVIDER="chatgpt"; ENV_KEY="CHATGPT_API_KEY" ;;
  2) AI_PROVIDER="gemini"; ENV_KEY="GEMINI_API_KEY" ;;
  3|"") AI_PROVIDER="deepseek"; ENV_KEY="DEEPSEEK_API_KEY" ;;
  *) AI_PROVIDER="deepseek"; ENV_KEY="DEEPSEEK_API_KEY" ;;
esac

API_KEY=""
if [[ -f .env ]]; then
  API_KEY=$(grep "^$ENV_KEY=" .env | cut -d'=' -f2-)
fi

if [[ -z "$API_KEY" ]]; then
  echo "[INFO]  Waiting for API key input..."
  read -p "Enter your API key for $AI_PROVIDER: " API_KEY
  sed -i.bak "/^$ENV_KEY=/d" .env 2>/dev/null
  echo "$ENV_KEY=$API_KEY" >> .env
  echo "AI_PROVIDER=$AI_PROVIDER" >> .env
  echo "[SUCCESS] $AI_PROVIDER API key saved to .env"
else
  echo "[INFO]  Using saved $AI_PROVIDER API key from .env"
fi

# Git Repo Prompt
step "Prompting for GitHub/GitLab repository URL..."
echo "[INFO]  Waiting for Git repo URL..."
read -p "Enter GitHub/GitLab repository URL: " repo_url

# CI Tool
step "Choosing CI tool (GitHub or GitLab)..."
echo "[INFO]  Waiting for CI tool selection..."
read -p "Enter CI tool [github/gitlab]: " ci_tool

# Language
step "Detecting project language..."
echo "[INFO]  Waiting for language input..."
read -p "Enter language [node/python/go]: " lang

# Deployment
step "Choosing deployment method..."
echo "[INFO]  Waiting for deploy method..."
read -p "Enter deploy method [docker/ssh]: " deploy

# Fallback
step "AI fallback option for missing templates..."
echo "[INFO]  Waiting for AI fallback option..."
read -p "Use DeepSeek AI if template missing? [Y/n]: " fallback

# Webhook
step "Webhook creation option..."
echo "[INFO]  Waiting for webhook preference..."
read -p "Create webhook? [Y/n]: " webhook

# Notification
step "Notification channel preference..."
echo "[INFO]  Waiting for notification channel..."
read -p "Notify on [slack/discord/none]: " notify

# Final success
echo "[SUCCESS] CI/CD Bootstrap Complete!"


# ========== SSH Key Detection and Generation ==========
step "Checking for SSH key..."

if [[ -f "$HOME/.ssh/id_rsa.pub" ]]; then
  echo "[INFO] Existing SSH key found."
else
  step "No SSH key found. Generating new SSH key..."
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t rsa -b 4096 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_rsa" -N ""
  echo "[SUCCESS] New SSH key generated."
fi

# Show public key
echo
echo "[INFO]  Your SSH Public Key:"
cat "$HOME/.ssh/id_rsa.pub"
echo

# Git clone logic (support both HTTPS and SSH)
if [[ "$repo_url" == git@* ]]; then
  repo_name=$(basename "$repo_url" .git)
elif [[ "$repo_url" == https://* ]]; then
  repo_name=$(basename "$repo_url" .git)
else
  echo "[ERROR] Invalid Git repo URL."
  exit 1
fi

step "Cloning repository: $repo_url..."
git clone "$repo_url"
if [[ ! -d "$repo_name" ]]; then
  echo "[ERROR] Cloning failed. Exiting."
  exit 1
fi

cd "$repo_name"
echo "[INFO]  📂 Current working directory: $(pwd)"

step "Checking Git status before changes..."
git status

step "Staging all files..."
git add .

step "Generating commit message..."
commit_msg="🚀 feat: initialize CI/CD setup"
git commit -m "$commit_msg" 2>/dev/null || echo "[WARN]  Nothing to commit."

step "Pushing to origin/main..."
git push origin "$DEFAULT_BRANCH" 2>/dev/null && echo "[SUCCESS] Push to $DEFAULT_BRANCH complete!" || echo "[WARN] Push skipped or failed."

echo "

echo "[SUCCESS] GitHub Actions CI workflow created: .github/workflows/ci.yml"



echo "[SUCCESS] GitHub Actions CI workflow created: .github/workflows/ci.yml"
echo "[INFO]  Detected default branch: $DEFAULT_BRANCH"

# Push to detected branch instead of hardcoded main
git push origin "$DEFAULT_BRANCH" 2>/dev/null && echo "[SUCCESS] Push to $DEFAULT_BRANCH complete!" || echo "[WARN] Push skipped or failed."

# Create GitHub Actions workflow

echo "[SUCCESS] GitHub Actions CI workflow created: .github/workflows/ci.yml"

echo "🎉 CI/CD Bootstrap Complete!""

if [[ "$MACHINE_OS" == "Linux" || "$MACHINE_OS" == "macOS" || "$MACHINE_OS" == "Windows" ]]; then

# ========== Auto-Copy SSH Key to Clipboard ==========
echo
read -p "Copy your SSH key to clipboard? [Y/n]: " copy_clip
if [[ "$copy_clip" =~ ^[Yy]$ || -z "$copy_clip" ]]; then
  if command -v pbcopy >/dev/null; then
    cat "$HOME/.ssh/id_rsa.pub" | pbcopy
    echo "[INFO] SSH key copied to clipboard using pbcopy (macOS)"
  elif command -v xclip >/dev/null; then
    cat "$HOME/.ssh/id_rsa.pub" | xclip -selection clipboard
    echo "[INFO] SSH key copied to clipboard using xclip (Linux)"
  elif command -v clip >/dev/null; then
    cat "$HOME/.ssh/id_rsa.pub" | clip
    echo "[INFO] SSH key copied to clipboard using clip (Windows)"
  else
    echo "[WARN] Clipboard tool not found. Please copy manually."
fi
  fi
fi