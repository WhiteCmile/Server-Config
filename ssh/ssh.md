# SSH 配置

## 1) 生成 SSH 密钥

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

按提示保存到默认路径（通常是 `~/.ssh/id_ed25519`）。

## 2) 上传公钥到 GitHub

```bash
cat ~/.ssh/id_ed25519.pub
```

复制输出内容，添加到 GitHub 的 SSH keys。

## 3) 配置 GitHub 别名主机

编辑 `~/.ssh/config`，添加：

```sshconfig
Host github.ztl
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```

建议同时设置权限：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519
```

## 4) 验证

```bash
ssh -T git@github.ztl
```

首次连接输入 `yes`，看到 GitHub 的欢迎提示即表示成功。
