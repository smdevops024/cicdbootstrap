# 🚀 cicd-bootstrap.sh – Universal CI/CD Setup Script

A professional-grade Bash script to bootstrap CI/CD pipelines for GitHub or GitLab, using Node.js, Python, or Go — with DeepSeek AI integration, secure key handling, and auto-push logic.

## 🧰 Features

- ✅ GitHub & GitLab CI support
- 🧠 DeepSeek AI-based config generation (auto fallback)
- 🔐 Secure `.env` API key loading
- 🚀 Auto commit & push to repo if config is updated
- 🧪 Dry-run preview mode
- 📩 Optional Slack/Discord notification embedding
- 🕸️ Webhook creation for GitHub

## ⚙️ Setup

### 1. Clone the Script or Download ZIP

```bash
git clone https://github.com/your-repo/cicd-bootstrap.git
cd cicd-bootstrap
chmod +x cicd-bootstrap.sh
```

### 2. Add Your API Keys to `.env`

```bash
cp .env.example .env
nano .env
```

Set:
```
DEEPSEEK_API_KEY=your_deepseek_key_here
GITHUB_TOKEN=your_github_token_here
```

## 🚀 Example Usage

### GitHub + Node + Docker

```bash
./cicd-bootstrap.sh \
  --repo https://github.com/example-org/app.git \
  --ci github \
  --lang node \
  --deploy docker \
  --use-deepseek \
  --notify slack \
  --create-webhook
```

### Dry Run Mode

```bash
./cicd-bootstrap.sh \
  --repo https://github.com/example-org/app.git \
  --ci github \
  --lang python \
  --deploy docker \
  --use-deepseek \
  --dry-run
```

## 🔒 Security Best Practices

- Never commit `.env` with real tokens.
- Store credentials securely using GitHub Secrets or a vault.

## 🧠 Requirements

- `bash` (Linux, macOS, Git Bash on Windows)
- `curl`, `jq`, `git`, `sed`

## 🛠️ Troubleshooting

- 🐞 Git not found? Install with `sudo apt install git`
- 🔐 GitHub push failing? Check if token has `repo` scope
- ❌ DeepSeek error? Check if API key is correct
