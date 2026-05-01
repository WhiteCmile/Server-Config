# Codex 配置

> 如何安装 codex 到指定目录并指定运行 codex 时的 `~/.codex` 目录

首先，我们需要安装 codex 到指定目录，在这之前需要先安装 `node.js`，比如说我们现在要安装在 `.../apps/codex` 下，那么就运行

```
npm install -g @openai/codex --prefix .../apps/codex
echo "export PATH=\".../apps/codex/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

用
```
which codex
codex --version
```
进行验证

然后我们不想所有人都共用我们自己的订阅，所以希望把 `~/.codex` 挪到比如说 `.../apps/codex/.codex` 下，那每次执行 codex 就应该是
```
CODEX_HOME=.../apps/codex/.codex codex
```
