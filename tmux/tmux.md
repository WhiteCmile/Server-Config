# tmux 配置指南

## 配置步骤

在仓库根目录执行，将 [`.tmux.conf`](./.tmux.conf) 复制到用户目录：

```bash
cp tmux/.tmux.conf ~/.tmux.conf
```

如果当前已经在 tmux 会话中，可立即重载：

```bash
tmux source-file ~/.tmux.conf
```

## 当前配置说明

该配置目前只开启了鼠标支持：

```tmux
set -g mouse on
```
