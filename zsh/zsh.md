# ZSH 配置

> 如何把 zsh 配置放到指定目录并启用

先保证服务器已安装 `zsh`，例如：

```
sudo apt update
sudo apt install -y zsh
```

然后把配置放到指定目录，比如我们这里统一放在：

```
APPS_HOME=/inspire/hdd/project/inference-chip/xujiaming-253308120313/ztl/apps
ZSH_HOME="$APPS_HOME/zsh"
```

把该目录里的配置文件软链接到用户家目录：

```
ln -sf "$ZSH_HOME/.zshrc" ~/.zshrc
ln -sf "$ZSH_HOME/.zprofile" ~/.zprofile
ln -sf "$ZSH_HOME/.zsh_aliases" ~/.zsh_aliases
ln -sf "$ZSH_HOME/.zsh_functions" ~/.zsh_functions
```

然后验证并进入 zsh：

```
zsh --version
exec zsh
```

如果暂时不改默认 shell，也可以先手动加载配置：

```
source ~/.zshrc
```

> 安装 powerlevel10k（p10k）

如果希望使用 `p10k` 主题，在同一个目录下安装：

```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_HOME/powerlevel10k"
```

然后重新进入 zsh，并执行向导：

```
exec zsh
p10k configure
```

`p10k configure` 会生成 `~/.p10k.zsh`。如果希望统一放到配置目录，可复制一份：

```
cp ~/.p10k.zsh "$ZSH_HOME/.p10k.zsh"
```
