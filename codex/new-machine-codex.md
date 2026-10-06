# New Machine: Codex-First 使用方式

目标：新机器只先装好 `codex`，其余环境让 Codex 按本仓库标准自动配置。

## 1) 给 Codex 的指令（可直接复制）

```text
你在一个服务器配置仓库里。请按以下要求执行：
1. 先阅读 README.md 和 codex/new-machine-codex.md。
2. 运行 bootstrap/setup_env.sh 完成基础环境配置。
3. APPS_HOME 使用 /path/to/apps（如果我没指定就默认用 $HOME/apps）。
4. 执行完成后，运行文档中的验证命令并汇报结果。
5. 如果某一步需要 sudo 权限，先继续执行不需要 sudo 的部分，并明确告诉我需要我补执行的命令。
6. Happy 配对需要我用手机扫码，最后提醒我按 happy/happy.md「新机器接入」开新终端执行 happy auth login 和 bash happy/install-daemon-service.sh。
```

## 2) Codex 实际会执行的命令

```bash
APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
```

## 3) 可选参数

按需通过环境变量控制行为：

```bash
INSTALL_BASE_PACKAGES=0 APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
SET_DEFAULT_SHELL_ZSH=1 APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
NODE_VERSION=v22.22.0 APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
SETUP_HAPPY=0 APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
```

变量说明：

- `INSTALL_BASE_PACKAGES`: `1/0`，是否安装 `curl/tar/git/tmux/vim/zsh` 等基础包
- `INSTALL_NODE`: `1/0`，是否安装 Node
- `SETUP_SSH_ALIAS`: `1/0`，是否写入 `~/.ssh/config` 的 `github.ztl`
- `SETUP_TMUX`: `1/0`，是否链接 tmux 配置
- `SETUP_VIM`: `1/0`，是否链接 vim 配置
- `SETUP_ZSH`: `1/0`，是否链接 zsh 配置
- `SET_DEFAULT_SHELL_ZSH`: `1/0`，是否执行 `chsh`
- `NODE_VERSION`: Node 版本（默认 `v22.22.0`）
- `SETUP_HAPPY`: `1/0`，是否安装 Happy 并默认用 `happy claude/codex` 启动（见 [happy.md](../happy/happy.md)）
- `HAPPY_SERVER_URL`: Happy 中转服务器（默认 `https://47.74.47.171`）
