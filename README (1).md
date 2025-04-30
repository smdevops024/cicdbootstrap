# 🚀 CI/CD Bootstrap Script v2.6

A powerful, secure, and OS-aware automation script designed for modern DevOps pipelines. This tool enables real-time AI-enhanced Git operations using your preferred AI model (ChatGPT, Gemini, or DeepSeek) to summarize diffs, analyze code, and suggest commit messages.

---

## 📌 Features

- 🔍 **OS Detection**: Automatically identifies Linux, macOS, or Windows.
- 🤖 **AI Integration**: Choose between ChatGPT, Gemini, or DeepSeek for live:
  - Code diff summaries
  - Bug/security analysis
  - Commit message generation
- 🔐 **Secure API Key Storage**: Automatically manages and secures your API keys in a `.env` file.
- 🔄 **Git Repository Handling**:
  - Clones a GitHub/GitLab repo
  - Auto-stages all files (including submodules)
  - Rebases and pushes to the correct branch
- ⚠️ **Error Logging**: All actions are logged in `cicd-log.txt` for audit and debugging.
- 📄 **Git Hygiene**: Automatically adds `.env`, logs, and unwanted files to `.gitignore` and `.gitattributes`.

---

## 🛠️ Requirements

- Git
- Bash (Linux/macOS or Git Bash on Windows)
- `jq` (for parsing AI responses)
- API key for one of:
  - OpenAI (ChatGPT)
  - Gemini
  - DeepSeek

---

## 🧑‍💻 Installation & Usage

1. **Clone the script**  
   ```bash
   git clone https://github.com/your-repo/cicd-bootstrap.git
   cd cicd-bootstrap
   chmod +x cicd-bootstrap.sh
   ```

2. **Run the Script**  
   ```bash
   ./cicd-bootstrap.sh
   ```

3. **Follow the Prompts**
   - Choose your AI provider
   - Paste your API key (stored securely)
   - Provide your GitHub/GitLab repo URL

---

## 📁 Files Automatically Managed

| File             | Purpose                           |
|------------------|-----------------------------------|
| `.env`           | Secure API key storage            |
| `cicd-log.txt`   | CI/CD logging                     |
| `push.log`       | Git push output                   |
| `.gitignore`     | Prevents sensitive/log files push |
| `.gitattributes` | Marks logs as export-ignore       |

---

## 📋 Sample Workflow

1. Detect OS → Prompt for AI model → Save API key
2. Clone your Git repo → Stage files
3. AI generates:
   - Summary of code changes
   - Code analysis
   - Commit message
4. Rebase from remote main → Push changes

---

## 🔐 Security

- API keys are never printed to terminal.
- Stored only in `.env` with restricted `chmod 600` access.
- Logs sensitive operations with timestamps.

---

## 🙌 Author

👑 **Raja Muhammad Awais**  
_Automate with precision. Secure with honor. Scale with vision. Lead with purpose._

---

## 🏷️ Version

**v2.6**


---

## 🌍 Run Script from Anywhere (Global Access)

### Option 1: Move to a Directory in Your `$PATH`

```bash
sudo mv cicd-bootstrap.sh /usr/local/bin/cicd-bootstrap
sudo chmod +x /usr/local/bin/cicd-bootstrap
```

Now run it globally from anywhere:

```bash
cicd-bootstrap
```

---

### Option 2: Use a Local Scripts Folder

```bash
mkdir -p ~/scripts
mv cicd-bootstrap.sh ~/scripts/cicd-bootstrap
chmod +x ~/scripts/cicd-bootstrap
```

Add to your shell config (`~/.bashrc` or `~/.zshrc`):

```bash
export PATH="$HOME/scripts:$PATH"
```

Then reload the shell:

```bash
source ~/.bashrc   # or use ~/.zshrc depending on your shell
```

You can now use `cicd-bootstrap` from anywhere.

