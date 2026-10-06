# Happy 配置

[Happy](https://github.com/slopus/happy) 让手机（iOS/Android App）远程查看和控制本机的 Claude Code / Codex 会话：给已有会话发消息、审批权限、新开会话。中转服务器为自建的 `https://47.74.47.171`。

## 一键配置

`bootstrap/setup_env.sh` 默认会执行 Happy 配置（`SETUP_HAPPY=1`）：

1. 安装 Happy CLI 到 `$APPS_HOME/happy`
2. 若 `~/.happy/settings.json` 不存在，写入 `serverUrl`（默认 `https://47.74.47.171`，可用 `HAPPY_SERVER_URL` 覆盖）
3. 让 bash/zsh 加载 [happy.sh](./happy.sh)，默认把 `claude` / `codex` 交给 Happy 启动

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

## 首次配对（每台机器一次）

1. 手机安装 Happy App，登录前在设置里把 Relay Server URL 改为 `https://47.74.47.171`
2. 机器上执行 `happy auth login`，用 App 扫二维码
3. 可选：`happy daemon start`，之后可以从手机上直接在这台机器新开会话

配对完成后会生成 `~/.happy/access.key`，wrapper 才会生效。

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
- 修改代理后需要重启 daemon：`happy daemon stop && happy daemon start`

## 常用命令

```bash
happy auth login      # 配对
happy daemon start    # 允许手机远程新开会话
happy daemon status
happy doctor          # 诊断
```

## 中转服务器

`happy-server-self-host` 部署在 `47.74.47.171`：systemd 服务 `happy-server`（监听 `127.0.0.1:3005`，数据在 `/var/lib/happy`，环境变量在 `/etc/happy/happy.env`），由 Caddy 用 Let's Encrypt IP 证书反代到 443。
