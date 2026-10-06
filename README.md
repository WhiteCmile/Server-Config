# Server Config

这个仓库用于集中管理常用服务器环境配置，包括 `node`、`codex`、`ssh`、`tmux`、`vim`、`vpn`、`zsh`、`happy`。

## Codex-First 快速开始

在新机器上，你只需要先确保 `codex` 可用，然后让 Codex 执行本仓库的初始化脚本：

1. 打开并阅读 [codex/new-machine-codex.md](./codex/new-machine-codex.md)
2. 按文档里的提示词直接发给 Codex
3. Codex 会执行 [bootstrap/setup_env.sh](./bootstrap/setup_env.sh) 自动完成大部分配置

## 目录说明

- `node/`: Node.js 安装说明
- `codex/`: Codex 安装与独立 `CODEX_HOME` 说明
- `ssh/`: SSH 密钥与 GitHub 别名配置
- `tmux/`: `tmux` 配置文件与使用说明
- `vim/`: `.vimrc` 配置文件与使用说明
- `vpn/`: 本地代理（mihomo/clash）配置与脚本
- `zsh/`: zsh 配置放置规范说明
- `happy/`: Happy 手机远程控制 Claude/Codex，默认用 `happy claude` / `happy codex` 启动
- `bootstrap/`: 一键初始化脚本（给 Codex 或人工执行）

## 推荐初始化顺序

1. 配置 SSH（先保证可以拉取私有仓库）
2. 安装 Node.js（为 npm/codex 提供运行环境）
3. 安装 Codex
4. 按需配置 `tmux`/`vim`/`zsh`
5. 按需配置 VPN 代理
6. 配置 Happy 并执行 `happy auth login` 与手机配对

## 文档入口

- [SSH 配置](./ssh/ssh.md)
- [Node 配置](./node/node.md)
- [Codex 配置](./codex/codex.md)
- [tmux 配置](./tmux/tmux.md)
- [Vim 配置](./vim/vim.md)
- [VPN 配置](./vpn/vpn.md)
- [Zsh 配置](./zsh/zsh.md)
- [Happy 配置](./happy/happy.md)
- [New Machine (Codex-First)](./codex/new-machine-codex.md)

## 约定

文档中的路径变量通常使用以下形式，请先按你的实际环境替换：

```bash
APPS_HOME=/path/to/apps
```
