# VPN 配置

> 使用 mihomo（来自 clash-party 的 sidecar）在服务器上启用本地代理

## 1) 下载并解压

先在 `https://github.com/mihomo-party-org/clash-party/releases` 下载适配系统架构的 `.deb` 文件，然后解压到目标目录：

```bash
CLASH_PATH=/path/to/clash
mkdir -p "$CLASH_PATH"
dpkg-deb -x clash-party-*.deb "$CLASH_PATH"
```

## 2) 创建可执行入口

```bash
cd "$CLASH_PATH"
ln -sf ./opt/clash-party/resources/sidecar/mihomo ./clash
```

## 3) 复制配置文件

在仓库根目录执行，将本仓库 `vpn/` 目录下文件复制到 `$CLASH_PATH`：

```bash
cp vpn/{Country.mmdb,GeoSite.dat,config.yaml,set_ztl_vpn.sh} "$CLASH_PATH"/
```

复制后应包含以下文件：

- `Country.mmdb`
- `GeoSite.dat`
- `config.yaml`
- `set_ztl_vpn.sh`（供终端启停代理）

目录结构应类似：

```text
$CLASH_PATH/
  clash
  Country.mmdb
  GeoSite.dat
  config.yaml
  set_ztl_vpn.sh
```

## 4) 调整端口

编辑 `config.yaml`，至少确认以下字段：

```yaml
mixed-port: 38478
external-controller: '127.0.0.1:10086'
```

如果端口冲突，请统一改成你自己的端口，并同步修改 `set_ztl_vpn.sh`。

脚本中的代理变量采用带协议前缀的形式（例如 `http://127.0.0.1:38478`），兼容性更好。

## 5) 启动 mihomo

```bash
cd "$CLASH_PATH"
./clash -d .
```

## 6) 在终端启用代理

```bash
source "$CLASH_PATH/set_ztl_vpn.sh"
proxy
```

关闭代理：

```bash
noproxy
```
