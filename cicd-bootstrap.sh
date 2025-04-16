#!/bin/bash

# cicd-bootstrap.sh
# Automates CI/CD pipeline setup for GitHub or GitLab projects.
# Compatible with Git Bash (Windows), Linux, and Ubuntu systems.

set -euo pipefail

# ========== LOGGING ==========
log_info() { echo -e "\033[1;34m[INFO]\033[0m  $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m  $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m  $1" >&2; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m  $1"; }

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
  log_error "Required parameters missing."
  echo "Usage: $0 --repo <url> --ci <github|gitlab> --lang <node|python|go> --deploy <docker|ssh> [--create-webhook] [--use-deepseek] [--dry-run] [--notify slack|discord]"
  exit 1
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
    git push origin "$BRANCH"
    log_success "CI config pushed to branch: $BRANCH"
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

log_success "CI/CD bootstrap completed for $REPO_DIR!"
