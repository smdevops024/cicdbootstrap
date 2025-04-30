#!/bin/bash

set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO. Exiting."' ERR

LOGFILE="cicd-log.txt"
echo "[INFO] Logging to $LOGFILE" | tee -a "$LOGFILE"

# ========== HEADER ==========
echo "[DEBUG] Loaded from: $0" | tee -a "$LOGFILE"
echo "[INFO]  CICD Bootstrap v2.6 — OS-aware & Real-Time AI-enhanced: $(date)" | tee -a "$LOGFILE"

# ========== OS DETECTION ==========
OS_TYPE="$(uname -s)"
case "${OS_TYPE}" in
    Linux*)     MACHINE_OS=Linux;;
    Darwin*)    MACHINE_OS=macOS;;
    MINGW*|MSYS*|CYGWIN*) MACHINE_OS=Windows;;
    *)          MACHINE_OS="UNKNOWN"
esac
echo "[INFO]  Detected OS: $MACHINE_OS" | tee -a "$LOGFILE"

step() {
  echo -e "\033[1;36m[STEP]\033[0m  $1" | tee -a "$LOGFILE"
}

# ========== BANNER ==========
echo -e "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;33m👑 Raja Muhammad Awais - DevOps\033[0m"
echo -e "\033[0;36mAutomate with precision. Secure with honor.\033[0m"
echo -e "\033[0;36mScale with vision. Lead with purpose.\033[0m"
echo -e "\033[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

SCRIPT_DIR=$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)
cd "$SCRIPT_DIR"

# ========== AI SELECTION ==========
step "Selecting AI model for CI/CD assistance..."
select ai_choice in "ChatGPT" "Gemini" "DeepSeek (default)"; do
  case $REPLY in
    1) AI_PROVIDER="chatgpt"; ENV_KEY="OPENAI_API_KEY"; break;;
    2) AI_PROVIDER="gemini"; ENV_KEY="GEMINI_API_KEY"; break;;
    3|"") AI_PROVIDER="deepseek"; ENV_KEY="DEEPSEEK_API_KEY"; break;;
    *) echo "[WARN] Invalid choice. Using DeepSeek."; AI_PROVIDER="deepseek"; ENV_KEY="DEEPSEEK_API_KEY"; break;;
  esac
done

# ========== SECURE API KEY ==========
step "Validating and storing API key securely..."
if [[ -f .env ]]; then
  API_KEY=$(grep "^$ENV_KEY=" .env | cut -d'=' -f2-)
fi

if [[ -z "${API_KEY:-}" ]]; then
  read -s -p "Enter your API key for $AI_PROVIDER: " API_KEY
  echo
  if [[ "$API_KEY" =~ ^sk-proj-[A-Za-z0-9_\-]{80,}$ ]]; then
    sed -i.bak "/^$ENV_KEY=/d" .env 2>/dev/null || true
    echo "$ENV_KEY=$API_KEY" >> .env
    echo "AI_PROVIDER=$AI_PROVIDER" >> .env
    chmod 600 .env
    echo "[SUCCESS] API key securely stored in .env" | tee -a "$LOGFILE"
  else
    echo "[ERROR] Invalid API key format." | tee -a "$LOGFILE"
    exit 1
  fi
else
  echo "[INFO]  Using secure $AI_PROVIDER API key from .env" | tee -a "$LOGFILE"
fi

# ========== ENSURE LOG FILES ARE IGNORED ==========
for ignore_item in ".env" "cicd-log.txt" "push.log"; do
  grep -qxF "$ignore_item" .gitignore || echo "$ignore_item" >> .gitignore
done

# ========== ADD export-ignore TO .gitattributes ==========
ATTR_FILE=".gitattributes"
for file in "cicd-log.txt" "push.log"; do
  if ! grep -q "^$file export-ignore" "$ATTR_FILE" 2>/dev/null; then
    echo "$file export-ignore" >> "$ATTR_FILE"
    echo "[INFO] Marked $file with export-ignore in .gitattributes" | tee -a "$LOGFILE"
  fi
done

# ========== GIT REPO ==========
step "Prompting for GitHub/GitLab repository URL..."
read -p "Enter GitHub/GitLab repository URL: " repo_url

step "Cloning repository: $repo_url..."
repo_name=$(basename "$repo_url" .git)
WORKDIR="$SCRIPT_DIR/$repo_name"
if [[ -d "$WORKDIR" && -n $(ls -A "$WORKDIR") ]]; then
  echo "[INFO]  Directory '$repo_name' already exists. Skipping clone." | tee -a "$LOGFILE"
else
  git clone --recurse-submodules=0 "$repo_url" "$WORKDIR" || { echo "[ERROR] Clone failed." | tee -a "$LOGFILE"; exit 1; }
fi
cd "$WORKDIR" || exit 1

# ========== STAGE FILES ==========
step "Staging all files..."
git submodule update --init --recursive || true
find . -type d -name ".git" -prune -o -type f -print0 | xargs -0 git add -f

# ========== AI ENHANCEMENTS ==========
DIFF=$(git diff --cached)
if [[ -z "$DIFF" ]]; then
  echo "[WARN] No staged changes detected. Skipping AI diff summary and analysis." | tee -a "$LOGFILE"
else
  step "Generating live AI summary of code diff..."
  SUMMARY_PROMPT="Summarize the following code diff in plain language:\n\n$DIFF"
  SUMMARY_JSON=$(mktemp)
  echo "{ \"model\": \"gpt-4\", \"messages\": [{\"role\": \"user\", \"content\": \"$SUMMARY_PROMPT\"}], \"max_tokens\": 300 }" > "$SUMMARY_JSON"
  SUMMARY_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "@${SUMMARY_JSON}")
  rm -f "$SUMMARY_JSON"
  SUMMARY_TEXT=$(echo "$SUMMARY_RESPONSE" | jq -r '.choices[0].message.content // empty')
  [[ -n "$SUMMARY_TEXT" ]] && echo -e "\n[INFO] AI Summary:\n$SUMMARY_TEXT" | tee -a "$LOGFILE"

  step "Running real-time AI code analysis..."
  ANALYSIS_PROMPT="Analyze this code diff for bugs, security issues, and bad practices:\n\n$DIFF"
  ANALYSIS_JSON=$(mktemp)
  echo "{ \"model\": \"gpt-4\", \"messages\": [{\"role\": \"user\", \"content\": \"$ANALYSIS_PROMPT\"}], \"max_tokens\": 300 }" > "$ANALYSIS_JSON"
  ANALYSIS_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "@${ANALYSIS_JSON}")
  rm -f "$ANALYSIS_JSON"
  ANALYSIS_TEXT=$(echo "$ANALYSIS_RESPONSE" | jq -r '.choices[0].message.content // empty')
  [[ -n "$ANALYSIS_TEXT" ]] && echo -e "\n[INFO] AI Code Analysis:\n$ANALYSIS_TEXT" | tee -a "$LOGFILE"
fi

# ========== COMMIT ==========
step "Generating AI-based commit message..."
COMMIT_PROMPT="Generate a Conventional Commit message for the following diff:\n\n$DIFF"
COMMIT_JSON=$(mktemp)
echo "{ \"model\": \"gpt-4\", \"messages\": [{\"role\": \"user\", \"content\": \"$COMMIT_PROMPT\"}], \"max_tokens\": 100 }" > "$COMMIT_JSON"
COMMIT_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "@${COMMIT_JSON}")
rm -f "$COMMIT_JSON"
COMMIT_MESSAGE=$(echo "$COMMIT_RESPONSE" | jq -r '.choices[0].message.content // "chore: initial commit"')
echo "[INFO] Suggested commit message: $COMMIT_MESSAGE"
read -p "Use this commit message? (Y/n): " confirm_commit
[[ "$confirm_commit" =~ ^[Nn]$ ]] && read -p "Enter your commit message: " COMMIT_MESSAGE
git commit -m "$COMMIT_MESSAGE"

# ========== REBASE & PUSH ==========
DEFAULT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
: "${DEFAULT_BRANCH:=main}"

step "Synchronizing with remote $DEFAULT_BRANCH..."
if ! git diff --quiet; then
  echo "[INFO] Stashing local changes before rebase..." | tee -a "$LOGFILE"
  git stash push -m "pre-rebase-auto-stash" || true
fi

git fetch origin "$DEFAULT_BRANCH" && git rebase origin/"$DEFAULT_BRANCH" || {
  echo "[ERROR] Rebase failed. Resolve conflicts manually." | tee -a "$LOGFILE"
  exit 1
}

step "Pushing to origin/$DEFAULT_BRANCH..."
git push origin "$DEFAULT_BRANCH" 2>&1 | tee push.log

if git stash list | grep -q 'pre-rebase-auto-stash'; then
  echo "[INFO] Restoring stashed changes..." | tee -a "$LOGFILE"
  git stash pop || {
    echo "[ERROR] Merge conflicts during stash pop. Resolve manually." | tee -a "$LOGFILE"
    git status
    exit 1
  }
fi

echo -e "\n🎉 [SUCCESS] CI/CD Bootstrap v2.6 Complete!"
