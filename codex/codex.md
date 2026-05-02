# Codex 配置

> 安装 Codex 到自定义目录，并将 `~/.codex` 改为项目内独立目录

## 前置条件

- Node.js 和 npm 可用（可先参考 [node/node.md](../node/node.md)）

## 安装 Codex

```bash
APPS_HOME=/path/to/apps
CODEX_INSTALL_DIR="$APPS_HOME/codex"

npm install -g @openai/codex --prefix "$CODEX_INSTALL_DIR"
echo "export PATH=\"$CODEX_INSTALL_DIR/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

## 验证安装

```bash
which codex
codex --version
```

## 使用独立的 `CODEX_HOME`

如果不希望所有人共享 `~/.codex`，可把配置目录放到安装目录下：

```bash
CODEX_HOME="$CODEX_INSTALL_DIR/.codex" codex
```

可选：增加一个快捷别名，避免每次手动写环境变量。

```bash
echo "alias codex-ztl='CODEX_HOME=$CODEX_INSTALL_DIR/.codex codex'" >> ~/.bashrc
source ~/.bashrc
```

之后可直接运行：

```bash
codex-ztl
```

## 新机器自动化（推荐）

如果你希望“只装好 Codex，其余交给 Codex 自动配置”，请直接看：

- [new-machine-codex.md](./new-machine-codex.md)
