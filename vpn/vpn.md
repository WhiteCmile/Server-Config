# VPN 配置

在 `https://github.com/mihomo-party-org/clash-party/releases` 下载对应的 mihomo .deb 文件

使用
```
dpkg-deb -x clash-party-*.deb $CLASH_PATH
```
其中 `$CLASH_PATH` 是你想安装 `clash` 的文件夹

然后执行
```
cd $CLASH_PATH
ln -s ./opt/clash-party/resources/sidecar/mihomo clash
```

将本仓库的 Country.mmdb, config.yaml, GeoSite.dat 复制一份到 `$CLASH_PATH` 目录

然后修改 `config.yaml` 中的 `mixed-port` 和 `external-controller` 为：
```
mixed-port: 38478
external-controller: '127.0.0.1:10086'
```

文件目录应该形如
```
clash
    - clash
    - Country.mmdb
    - config.yaml
    - GeoSite.dat
```

然后 `./clash -d .` 

在需要用梯子的终端中复制一份本文件夹下的 `set_ztl_vpn.sh`
然后
```
source set_ztl_vpn.sh
proxy
```
即可使用代理
