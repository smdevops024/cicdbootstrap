#!/bin/bash

# cicd-bootstrap.sh
# Automates CI/CD pipeline setup for GitHub or GitLab projects.
# Compatible with Git Bash (Windows), Linux, and Ubuntu systems.

set -euo pipefail

VERSION="1.3.0"

if [[ "$1" == "--version" ]]; then
  echo "cicd-bootstrap.sh version $VERSION"
  exit 0
fi


# ========== LOGGING ==========
log_info() { echo -e "\033[1;34m[INFO]\033[0m  $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m  $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m  $1" >&2; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m  $1"; }


# ========== GLOBAL ERROR TRAP HANDLER ==========
trap 'handle_error $? "$BASH_COMMAND"' ERR

handle_error() {
  local exit_code=$1
  local failed_command=$2

  log_error "Command failed: $failed_command"
  echo "Exit code: $exit_code"

  # Ask DeepSeek for fix
  if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
    log_warn "DeepSeek API key is not set. Skipping AI resolution."
    exit $exit_code
  fi

  log_info "Analyzing error using DeepSeek AI..."

  prompt="The following command failed in a Bash script:\n\nCommand: $failed_command\nExit Code: $exit_code\n\nSuggest a fix with a one-line bash command to resolve the issue. Provide ONLY the command."

  fix_command=$(curl -s -X POST "https://api.deepseek.com/v1/chat/completions" \
    -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "deepseek-chat",
      "messages": [
        { "role": "user", "content": "'"$prompt"'" }
      ]
    }' | jq -r '.choices[0].message.content')

  echo "$fix_command" > .deepseek-fix.log
  log_warn "AI suggested fix: $fix_command"

  read -rp "Do you want to run this fix? (Y/n): " confirm
  if [[ -z "$confirm" || "$confirm" =~ ^[Yy]$ ]]; then
    eval "$fix_command"
    log_success "Fix command executed. Resuming script..."
  else
    log_warn "Fix skipped. Exiting with original error code."
    exit $exit_code
  fi
}


# ========== ARGUMENT PARSING ==========
REPO="" CI_TOOL="" LANG="" DEPLOY=""
CREATE_WEBHOOK=false
USE_DEEPSEEK=false
DRY_RUN=false
NOTIFY=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --repo) REPO="$2"; shift ;;
    --ci) CI_TOOL="$2"; shift ;;
    --lang) LANG="$2"; shift ;;
    --deploy) DEPLOY="$2"; shift ;;
    --create-webhook) CREATE_WEBHOOK=true ;;
    --use-deepseek) USE_DEEPSEEK=true ;;
    --dry-run) DRY_RUN=true ;;
    --notify) NOTIFY="$2"; shift ;;
    *) log_error "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

# ========== VALIDATION ==========
if [[ -z "$REPO" || -z "$CI_TOOL" || -z "$LANG" || -z "$DEPLOY" ]]; then
  log_warn "Required parameters missing. Switching to interactive mode..."

  if [[ -z "$REPO" ]]; then
    read -rp "Enter GitHub/GitLab repository URL: " REPO
  fi

  if [[ -z "$CI_TOOL" ]]; then
    read -rp "Enter CI tool (github/gitlab): " CI_TOOL
  fi

  if [[ -z "$LANG" ]]; then
    read -rp "Enter language (node/python/go): " LANG
  fi

  if [[ -z "$DEPLOY" ]]; then
    read -rp "Enter deploy method (docker/ssh): " DEPLOY
  fi

  read -rp "Use DeepSeek AI if template missing? (Y/n): " USE_DS
  [[ -z "$USE_DS" || "$USE_DS" =~ ^[Yy]$ ]] && USE_DEEPSEEK=true

  read -rp "Create webhook? (Y/n): " CREATE_WH
  [[ -z "$CREATE_WH" || "$CREATE_WH" =~ ^[Yy]$ ]] && CREATE_WEBHOOK=true

  read -rp "Enable dry-run? (Y/n): " DRY
  [[ -z "$DRY" || "$DRY" =~ ^[Yy]$ ]] && DRY_RUN=true

  read -rp "Notify on (slack/discord/none): " NOTIFY_INPUT
  [[ "$NOTIFY_INPUT" != "none" ]] && NOTIFY="$NOTIFY_INPUT"
fi

REPO_DIR=$(basename "$REPO" .git)

# ========== CLONE REPO ==========
if [ -d "$REPO_DIR" ]; then
  log_warn "Directory '$REPO_DIR' already exists. Skipping clone."
else
  log_info "Cloning repository $REPO..."
  git clone "$REPO"
  log_success "Repository cloned into $REPO_DIR"
fi

cd "$REPO_DIR"

# ========== CI/CD CONFIG ==========
CONFIG_DEST=""
case "$CI_TOOL" in
  github)
    mkdir -p .github/workflows
    CONFIG_SRC="../templates/github-${LANG}.yml"
    CONFIG_DEST=".github/workflows/ci.yml"
    ;;
  gitlab)
    CONFIG_SRC="../templates/gitlab-${LANG}.yml"
    CONFIG_DEST=".gitlab-ci.yml"
    ;;
  *) log_error "Unsupported CI tool: $CI_TOOL"; exit 1 ;;
esac

# === DeepSeek fallback ===
if [ ! -f "$CONFIG_SRC" ]; then
  if $USE_DEEPSEEK; then
    if [ -f "../.env" ]; then
      source ../.env
    fi
    DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY:-sk-b2d45077b78548a58392441e09d0f188}"
    if [ -z "$DEEPSEEK_API_KEY" ]; then
      log_error "DEEPSEEK_API_KEY is missing. Set it via env var or .env file."
      exit 1
    fi

    prompt="Generate a CI/CD workflow for a $LANG project using $CI_TOOL CI and deploying via $DEPLOY. Include build, test, and deploy stages."
    if [ -n "$NOTIFY" ]; then
      prompt+=" Also add $NOTIFY notifications."
    fi

    log_info "Querying DeepSeek AI..."

    curl -s -X POST "https://api.deepseek.com/v1/chat/completions"       -H "Authorization: Bearer $DEEPSEEK_API_KEY"       -H "Content-Type: application/json"       -d '{
        "model": "deepseek-chat",
        "messages": [
          { "role": "user", "content": "'"$prompt"'" }
        ]
      }' | jq -r '.choices[0].message.content' > "$CONFIG_DEST"

    if [[ -s "$CONFIG_DEST" ]]; then
      log_success "DeepSeek AI generated config at $CONFIG_DEST"
    else
      log_error "Failed to generate config from DeepSeek."
      exit 1
    fi
  else
    log_error "Missing CI template: $CONFIG_SRC"
    exit 1
  fi
else
  cp "$CONFIG_SRC" "$CONFIG_DEST"
  log_success "CI config copied to $CONFIG_DEST"
fi

if $DRY_RUN; then
  log_info "Dry-run mode enabled. CI config preview:"
  cat "$CONFIG_DEST"
  exit 0
fi

# ========== DEPLOY SCRIPT ==========
DEPLOY_SRC="../deploy/deploy-${DEPLOY}.sh"
DEPLOY_DEST="./deploy.sh"

if [ ! -f "$DEPLOY_SRC" ]; then
  log_error "Missing deployment script: $DEPLOY_SRC"
  exit 1
fi

cp "$DEPLOY_SRC" "$DEPLOY_DEST"
chmod +x "$DEPLOY_DEST"
log_success "Deployment script ready at $DEPLOY_DEST"

# ========== AUTO COMMIT & PUSH CI CONFIG ==========
if git rev-parse --git-dir > /dev/null 2>&1; then
  if ! git diff --quiet "$CONFIG_DEST"; then
    log_info "Detected changes — committing CI config..."
    git add "$CONFIG_DEST"
    git commit -m "Add/Update CI config for $LANG with $CI_TOOL"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    if ! git push origin "$BRANCH"; then
    log_error "Git push failed. Attempting to analyze error using DeepSeek..."

    ERROR_LOG=$(git status && git log -1 && git remote -v)
    prompt="I encountered an error while pushing code to GitHub. Here's the error context:
$ERROR_LOG
Please analyze and regenerate the correct git command using DeepSeek AI."

    if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
      log_error "DEEPSEEK_API_KEY not set. Skipping DeepSeek error resolution."
    else
      fix_command=$(curl -s -X POST "https://api.deepseek.com/v1/chat/completions" \
        -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
          "model": "deepseek-chat",
          "messages": [
            { "role": "user", "content": "'"$prompt"'" }
          ]
        }' | jq -r '.choices[0].message.content')

      echo "$fix_command" > ../deepseek_git_fix_command.sh
      log_info "AI suggested fix command saved to deepseek_git_fix_command.sh"
      read -rp "Do you want to run this suggested command? (Y/n): " confirm_run
      if [[ -z "$confirm_run" || "$confirm_run" =~ ^[Yy]$ ]]; then
        bash ../deepseek_git_fix_command.sh
        log_success "Suggested command executed."
      else
        log_warn "User skipped running suggested command."
      fi
    fielse
        curl -s -X POST "https://api.deepseek.com/v1/chat/completions" \
          -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
          -H "Content-Type: application/json" \
          -d '{
            "model": "deepseek-chat",
            "messages": [
              { "role": "user", "content": "'"$prompt"'" }
            ]
          }' | jq -r '.choices[0].message.content' > ../deepseek_git_error_resolution.txt

        log_info "DeepSeek analysis saved to deepseek_git_error_resolution.txt"
        cat ../deepseek_git_error_resolution.txt
      fi
    else
      log_success "CI config pushed to branch: $BRANCH"
    fi

  else
    log_info "No changes to push."
  fi
else
  log_warn "Not a Git repository — skipping push."
fi

# ========== CREATE GITHUB WEBHOOK ==========
if $CREATE_WEBHOOK && [[ "$CI_TOOL" == "github" ]]; then
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    log_error "GITHUB_TOKEN not set."
    exit 1
  fi
  REPO_API_URL=$(echo "$REPO" | sed -E 's|https://github.com/([^/]+)/([^\.]+)\.git|\1/\2|')
  API_ENDPOINT="https://api.github.com/repos/${REPO_API_URL}/hooks"

  log_info "Creating webhook for GitHub repo: $REPO_API_URL"

  curl -s -X POST "$API_ENDPOINT"     -H "Authorization: token $GITHUB_TOKEN"     -H "Accept: application/vnd.github+json"     -d '{
      "name": "web",
      "active": true,
      "events": ["push", "pull_request"],
      "config": {
        "url": "https://example.com/webhook",
        "content_type": "json"
      }
    }' | grep -q '"id":'

  if [ $? -eq 0 ]; then
    log_success "Webhook created successfully."
  else
    log_error "Webhook creation failed."
  fi
fi

log_success "✅ Final CI/CD Bootstrap Script Menu (v1.3.0) Completed for $REPO_DIR!"
