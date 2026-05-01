# VPN 配置

在 `https://github.com/Kuingsmile/clash-core/releases` 下载对应的 clash 二进制文件并解压命名为 `clash`

将本仓库的 Country.mmdb 复制一份

从代理网站拷贝 `config.yaml`，命令形如
```
wget -O config.yaml https://s.suying666.info/link/***?clash=1&log-level=info
```

然后修改 `config.yaml` 中的
```
mixed-port: 38478
```

文件目录应该形如
```
clash
    - clash
    - Country.mmdb
    - config.yaml
```

然后 `./clash -d .` 

在需要用梯子的终端中复制一份本文件夹下的 `set_ztl_vpn.sh`
然后
```
source set_ztl_vpn.sh
proxy
```
即可使用代理
