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

该配置包含：

```tmux
set -g mouse on
bind-key -T root MouseDrag1Pane copy-mode -M
set -s set-clipboard external
set -g default-terminal "xterm-256color"
set -g update-environment "LANG LC_ALL"
```

- 开启 tmux 鼠标支持。
- 鼠标左键拖动时直接选择，松开后自动复制，不需要先按 `Ctrl-b [`。
- 通过 OSC 52 将 tmux 中复制的文字写入发起 SSH 连接的本地终端剪贴板。
- 保留终端类型以及 `LANG`、`LC_ALL` 环境变量更新配置。

鼠标拖动会固定用于 tmux 复制，不再传给 Codex、Vim 等前台程序；滚轮和普通单击不受影响。

## 本地终端要求

本地终端必须支持并允许 OSC 52。macOS 推荐使用 iTerm2，并开启：

```text
Settings → General → Applications in terminal may access clipboard
```

从其他终端切换到 iTerm2 时，不需要创建新的 tmux window 或 session。先从原终端 detach，再在 iTerm2 中重新连接：

```text
Ctrl-b d
```

```bash
ssh <server>
tmux attach -t <session-name>
```

在 iTerm2 中还可以按住 `Option` 再拖动，绕过 tmux，使用终端原生选择。

## 验证

重新连接 tmux 后检查：

```bash
tmux show-options -s set-clipboard
tmux list-keys -T root | grep MouseDrag1Pane
tmux list-clients -F '#{client_termname} #{client_termfeatures}'
```

预期结果应包含：

```text
set-clipboard external
MouseDrag1Pane ... copy-mode -M
clipboard
```

如果曾配置过 `copy-command` 调用远端的 `pbcopy`、`xclip` 或 `xsel`，应删除该配置并重启 tmux server；否则复制内容可能只进入远端机器的剪贴板。不要在仍有重要任务运行时执行 `tmux kill-server`。
