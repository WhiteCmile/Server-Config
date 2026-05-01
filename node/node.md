# Node 配置

> 如何在服务器上下载 node

先创建好对应的文件夹，在对应文件夹中执行：

```
curl -LO https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-x64.tar.xz
tar -xf node-v22.11.0-linux-x64.tar.xz
mv node-v22.11.0-linux-x64 node
```

会得到一个名为 `node` 的文件夹，然后运行

```
cd node
echo "export PATH=\"$(pwd)/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

然后输入

```
node -v
```

确定是否安装成功
