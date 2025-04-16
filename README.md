# 🚀 CI/CD Bootstrap Script v1.3.0

Automate your CI/CD pipeline setup for GitHub or GitLab repositories with a single script — compatible with Bash on Linux, Ubuntu, and Git Bash on Windows.

---

## 📦 Features

- ✅ Interactive and command-line setup options
- 🔁 Compatible with GitHub Actions & GitLab CI/CD
- 🧠 Fallback CI config generation using **DeepSeek AI**
- 🐳 Supports deployment via Docker or SSH
- 🔔 Slack or Discord notifications
- 📩 Auto-commit and push CI config
- 🧪 Dry-run mode for config preview
- 📬 GitHub webhook creation
- 🚨 Smart error handling with AI-suggested fixes

---

## 🛠️ Installation

1. **Clone or download** the repository containing `cicd-bootstrap.sh`.
2. Make the script executable:

```bash
chmod +x cicd-bootstrap.sh
```

3. Run the script using Bash:

```bash
./cicd-bootstrap.sh
```

> 💡 Works on Linux, macOS, and Git Bash for Windows.

---

## ⚙️ Usage

### 🔹 Basic CLI Example:

```bash
./cicd-bootstrap.sh \
  --repo https://github.com/your-org/your-repo.git \
  --ci github \
  --lang node \
  --deploy docker \
  --create-webhook \
  --use-deepseek \
  --notify slack
```

### 🔹 Interactive Mode:

Simply run the script without arguments and follow the prompts:

```bash
./cicd-bootstrap.sh
```

---

## 🔁 Workflow

1. **Clone repository**
2. **Select CI tool**: GitHub or GitLab
3. **Choose language**: Node.js, Python, Go
4. **Pick deployment method**: Docker or SSH
5. **Generate CI/CD config**
   - Uses templates if available
   - Falls back to **DeepSeek AI** if not
6. **Copy or generate deploy script**
7. **Auto-commit & push to repo**
8. *(Optional)* Create webhook for GitHub
9. *(Optional)* Notify via Slack or Discord

---

## 🧠 DeepSeek AI

If your preferred config is missing, the script uses DeepSeek AI to generate one. Make sure your `.env` file contains:

```env
DEEPSEEK_API_KEY=your_deepseek_api_key
```

---

## 🧪 Dry Run

Preview CI config before applying:

```bash
./cicd-bootstrap.sh --dry-run ...
```

---

## 🔐 Environment Variables

| Variable           | Description                        |
|--------------------|------------------------------------|
| `GITHUB_TOKEN`     | Required to create GitHub webhooks |
| `DEEPSEEK_API_KEY` | Required for AI-based generation   |

---

## 🧩 File Structure

```
.
├── cicd-bootstrap.sh
├── templates/
│   ├── github-node.yml
│   ├── github-python.yml
│   └── gitlab-node.yml
└── deploy/
    ├── deploy-docker.sh
    └── deploy-ssh.sh
```

---

## 📄 License

MIT License © 2025 - Made with 💻 by Steam Minds

---

## 🤝 Contributions

Pull requests welcome. For major changes, please open an issue first to discuss what you would like to change.
