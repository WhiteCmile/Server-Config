# Node 配置

> 在服务器上安装 Node.js 到自定义目录（不依赖系统包管理器）

## 前置条件

- 已安装 `curl`、`tar`
- 有一个用于存放工具的目录（如 `APPS_HOME`）

## 安装步骤

```bash
APPS_HOME=/path/to/apps
NODE_VERSION=v22.22.0
cd "$APPS_HOME"

curl -LO "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz"
tar -xf "node-${NODE_VERSION}-linux-x64.tar.xz"
mv "node-${NODE_VERSION}-linux-x64" node
```

## 配置 PATH

```bash
echo "export PATH=\"$APPS_HOME/node/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

## 验证

```bash
node -v
npm -v
npx -v
```

如果以上命令都能输出版本号，说明安装成功。
