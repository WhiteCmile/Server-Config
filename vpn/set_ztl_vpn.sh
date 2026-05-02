#!/bin/bash

proxy() {
    export http_proxy=http://127.0.0.1:38478
    export https_proxy=http://127.0.0.1:38478
    echo "Proxy On"
}

noproxy() {
    unset http_proxy
    unset https_proxy
    echo "Proxy Off"
}
