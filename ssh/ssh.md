# SSH 配置

> 创建公钥

```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

添加完成后在 github 上给该公钥添加授权

> 服务器 ssh 加别名

在 `~/.ssh/config` 上添加
```
Host github.ztl
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```