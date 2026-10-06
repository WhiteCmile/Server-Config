# Happy 配置

[Happy](https://github.com/slopus/happy) 让手机（iOS/Android App）远程查看和控制本机的 Claude Code / Codex 会话：给已有会话发消息、审批权限、新开会话。中转服务器为自建的 `https://47.74.47.171`。

## 一键配置

`bootstrap/setup_env.sh` 默认会执行 Happy 配置（`SETUP_HAPPY=1`）：

1. 安装 Happy CLI 到 `$APPS_HOME/happy`
2. 若 `~/.happy/settings.json` 不存在，写入 `serverUrl`（默认 `https://47.74.47.171`，可用 `HAPPY_SERVER_URL` 覆盖）
3. 让 bash/zsh 加载 [happy.sh](./happy.sh)，默认把 `claude` / `codex` 交给 Happy 启动

配对和 daemon 需要人工操作，见下方「新机器接入」。

## 手动安装

```bash
npm install -g happy --prefix "$APPS_HOME/happy"
# npm >= 11 可能跳过 install scripts，手动解包附带工具（重复执行无副作用）
node "$APPS_HOME/happy/lib/node_modules/happy/scripts/unpack-tools.cjs"

mkdir -p ~/.happy
echo '{"schemaVersion":2,"onboardingCompleted":false,"serverUrl":"https://47.74.47.171"}' > ~/.happy/settings.json

# zsh 由仓库的 .zshrc 自动加载；bash 需要：
echo '[ -f "/path/to/Server-Config/happy/happy.sh" ] && . "/path/to/Server-Config/happy/happy.sh"' >> ~/.bashrc
```

## 新机器接入（每台机器一次）

前提：机器上已经装好 `claude` / `codex`；需要代理才能上网的机器，下面每一步之前先执行 `proxy`。

1. 跑 bootstrap（或者已经有仓库的机器 `git pull` 后再跑一遍）：
   ```bash
   cd ~/Server-Config && APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
   ```
2. **开一个新终端**（旧终端没有加载 `happy.sh`，代理修复也不会生效）
3. 配对：
   ```bash
   happy auth login
   ```
   手机打开 Happy App → 扫终端里的二维码
4. 把 daemon 装成开机自启的 systemd 用户服务（让手机能看到这台机器、远程新开会话）：
   ```bash
   bash ~/Server-Config/happy/install-daemon-service.sh
   systemctl --user status happy-daemon    # active (running)
   ```
   - 在平时用的终端里执行：会记下当前的 `http_proxy/https_proxy`（存到 `~/.config/happy-daemon.env`），daemon 通过你的登录 shell（`bash -ic` / `zsh -ic`）启动，所以 PATH、模型 API 等环境变量和终端里一致
   - 挂了会自动重启；重启机器后自动起来需要 linger，脚本检测到没开时会提示执行 `sudo loginctl enable-linger $USER`
   - 改了代理后重新执行一次脚本；卸载：`bash ~/Server-Config/happy/install-daemon-service.sh --uninstall`
   - 没有 systemd 的机器用 `happy daemon start` 手动启动（重启后需要再执行）
5. 之后直接 `claude` / `codex` 即可，手机上能看到会话

配对后会生成 `~/.happy/access.key`，有它 wrapper 才会生效；没配对的机器上 `claude` / `codex` 照常走原生命令。

### 手机 App（只需设置一次）

- App Store 搜 **Happy Coder**（或从 [GitHub](https://github.com/slopus/happy) README 的 App Store 按钮进入）
- **登录前**：欢迎页右上角齿轮 → Server URL 填 `https://47.74.47.171` → 确认
- 已经用官方服务器登录过的话：设置里退出登录（Log out / Start over），回到欢迎页再改

### 把已在运行的会话接到手机上

已经用原生命令启动的进程 Happy 接管不了，需要退出后在**同一目录**用 Happy 恢复（对话内容不会丢）：

```bash
claude -c                     # 恢复这个目录最近一次对话
claude --resume [session-id]  # 指定或从列表选择
codex --resume <thread-id>    # thread-id 见 ~/.codex/sessions/ 下文件名末尾的 UUID
```

注意 `codex resume`（子命令形式）不会走 Happy。

## 默认用 Happy 启动

加载 `happy.sh` 后，在终端里交互式启动时：

| 输入 | 实际执行 |
| --- | --- |
| `claude`、`claude -c`、`claude --resume ...`、`claude --model opus` | `happy claude ...` |
| `codex`、`codex --model ... --yolo`、`codex --resume <id>` | `happy codex ...` |
| `claude -p ...`、`claude mcp ...`、`claude "prompt"`、`--version/--help` | 原生 `claude` |
| `codex exec ...`、`codex login`、`codex "prompt"`、`codex -c k=v` | 原生 `codex` |

规则：

- 只有满足以下条件才走 Happy：已安装 `happy`、已配对（存在 `~/.happy/access.key`）、stdin/stdout 都是终端
- `happy codex` 只支持 `--model`、`--effort`、`--permission-mode`、`--yolo`、`--no-sandbox`、`--resume`；带其他参数时直接用原生 `codex`，避免参数被丢掉
- 临时绕过：`command codex ...` / `command claude ...`
- 全局关闭：`export HAPPY_WRAP=0`

## 代理

需要代理才能访问中转服务器的机器（先执行 `proxy`，见 `zsh/.zsh_functions`）：

- `happy.sh` 设置 `NODE_USE_ENV_PROXY=1`，让 Node（>= 22.21 / 24）的 HTTP 请求走 `http_proxy/https_proxy`；同时把 `127.0.0.1,localhost` 加进 `NO_PROXY`，否则 daemon 自检会失败（"Failed to start daemon"）
- Happy 的实时连接（socket.io / `ws`）不认上面的代理设置，会直连然后超时，手机上显示 "Happy is not running on your computer"。`happy.sh` 里的 `happy()` 会通过 `NODE_OPTIONS=--require` 预加载 [ws-proxy.cjs](./ws-proxy.cjs)，把 WebSocket 也走代理；没有设置代理时它什么都不做
- 修改代理后需要重新执行 `install-daemon-service.sh`（手动启动的话 `happy daemon stop && happy daemon start`）

## 排查

| 现象 | 原因 / 处理 |
| --- | --- |
| `Happy server unreachable ... 500` | 中转服务器出错，看 `sudo journalctl -u happy-server`（见 [server/server.md](./server/server.md)） |
| `Failed to start daemon` | `NO_PROXY` 没包含 `127.0.0.1`，在新终端（已加载 `happy.sh`）里重试 |
| 手机显示 "Happy is not running on your computer" | daemon 没启动，或实时连接没走代理：`systemctl --user restart happy-daemon`（手动启动的话在新终端里 `happy daemon stop && happy daemon start`），日志里应有 `Connected to server` |
| daemon 服务起不来 | `journalctl --user -u happy-daemon -n 50`；开头的 `no job control in this shell` 是无害警告 |
| 手机看不到某个会话 | 该会话是原生命令启动的，按上面的方法用 Happy 恢复 |

日志在 `~/.happy/logs/`，daemon 日志文件名以 `-daemon.log` 结尾。

## 常用命令

```bash
happy auth login      # 配对
systemctl --user status happy-daemon   # daemon 服务状态
journalctl --user -u happy-daemon -f   # daemon 服务日志
happy daemon status
happy doctor          # 诊断
```

## 中转服务器

`happy-server-self-host` 部署在 `47.74.47.171`，部署方式、配置模板和已知问题见 [server/server.md](./server/server.md)。
