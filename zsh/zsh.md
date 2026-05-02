# ZSH 配置

> 使用仓库内置的 zsh 配置模板并启用

## 前置条件

```bash
sudo apt update
sudo apt install -y zsh
```

## 仓库内置文件

当前仓库 `zsh/` 目录已包含：

- `.zshrc`
- `.zprofile`
- `.zsh_aliases`
- `.zsh_functions`

## 手动启用

在仓库根目录执行：

```bash
ln -sfn zsh/.zshrc ~/.zshrc
ln -sfn zsh/.zprofile ~/.zprofile
ln -sfn zsh/.zsh_aliases ~/.zsh_aliases
ln -sfn zsh/.zsh_functions ~/.zsh_functions
```

然后验证：

```bash
zsh --version
exec zsh
```

## 通过初始化脚本启用（推荐）

```bash
APPS_HOME=$HOME/apps bash bootstrap/setup_env.sh
```

## 可选：设置默认 shell

```bash
chsh -s "$(which zsh)"
```
