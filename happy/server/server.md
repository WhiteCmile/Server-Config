# Happy 中转服务器部署

当前部署在 `admin@47.74.47.171`（Ubuntu 24.04，约 900 MB 内存 + 2 GB swap）。只有重装或换服务器时才需要看这一页；日常加新机器见 [../happy.md](../happy.md)。

## 组成

| 项 | 位置 |
| --- | --- |
| 程序 | `/opt/happy-server/node_modules/happy-server-self-host`（npm 包 `happy-server-self-host`） |
| 服务 | systemd `happy-server`，见 [happy-server.service](./happy-server.service)，以 `happy` 用户运行 |
| 配置 | `/etc/happy/happy.env`（600），模板见 [happy.env.example](./happy.env.example) |
| 数据 | `/var/lib/happy`（PGlite 内嵌数据库，备份这个目录即可） |
| HTTPS | Caddy 反代 `443 -> 127.0.0.1:3005`，见 [Caddyfile.snippet](./Caddyfile.snippet) |

## 部署步骤

小内存服务器上直接 `npm install` 容易卡死，建议在另一台 Linux x64 机器上装好依赖再打包上传（大文件经代理 SSH 传输会断，可以 `split -b 10m` 分块传再 `cat` 合并并校验 md5）。

```bash
# 1. 构建（在构建机上）
mkdir happy-build && cd happy-build && npm init -y
npm install happy-server-self-host
cd node_modules/happy-server-self-host

# npm >= 11 会跳过 install scripts，需要手动生成 Prisma client
chmod +x ../prisma-json-types-generator/index.js
PATH="$PWD/../.bin:$PATH" npx prisma generate --schema=prisma/schema.prisma

# 依赖修正：包里写的 pglite-prisma-adapter ^0.7.2 需要 Prisma 7，
# 但服务端用的是 Prisma 6.19.2，二进制字段会报 500（P2023 dataEncryptionKey）。
# 单独装一份配 Prisma 6 的 0.6.1，连同它的依赖嵌套放进包内：
(tmp=$(mktemp -d) && cd "$tmp" && npm init -y >/dev/null \
  && npm install --legacy-peer-deps pglite-prisma-adapter@0.6.1 \
  && mkdir -p node_modules/pglite-prisma-adapter/node_modules \
  && cp -r node_modules/postgres-array node_modules/@prisma node_modules/pglite-prisma-adapter/node_modules/ \
  && echo "$tmp")
mkdir -p node_modules
cp -r <上面输出的目录>/node_modules/pglite-prisma-adapter node_modules/

# 删掉 webapp：iOS App 校验服务器时要求 GET / 返回 "Welcome to Happy Server!"，
# 有 webapp 时 / 返回的是网页
rm -rf webapp

cd ../.. && tar czf happy-server.tgz node_modules
```

```bash
# 2. 服务器上
sudo useradd --system --home /var/lib/happy --shell /usr/sbin/nologin happy
sudo mkdir -p /opt/happy-server /var/lib/happy /etc/happy
sudo tar xzf happy-server.tgz -C /opt/happy-server
sudo chown -R happy:happy /var/lib/happy
sudo install -m 600 happy.env.example /etc/happy/happy.env   # 然后改 HANDY_MASTER_SECRET
sudo cp happy-server.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now happy-server

# 3. Caddy：把 Caddyfile.snippet 合并进 /etc/caddy/Caddyfile（先备份）
#    Caddyfile 里有 `admin off`，reload 不可用，要 restart
sudo systemctl restart caddy
```

## 验证

```bash
curl https://47.74.47.171/          # Welcome to Happy Server!
curl https://47.74.47.171/health    # {"status":"ok",...}
sudo journalctl -u happy-server -f
```

## 注意

- `HANDY_MASTER_SECRET` 不要提交到仓库，也不要改：改了之后所有已配对的设备都要重新登录
- 内存限制：`MemoryHigh=450M`、`MemoryMax=550M`，常驻约 400 MB
- 防火墙只需要放行 22/80/443
