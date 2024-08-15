#!/usr/bin/env bash
set -e

image_name=$1

# 如果传入参数为空，退出
if [ -z "$image_name" ]; then
    echo "No image_name found"
    exit 1
fi

proxy_hosts=("dockerpull.com" "dockerproxy.cn" "dockerhub.icu" "dockerhub.timeweb.cloud" "do.nark.eu.org" "docker.1panel.live" "docker.registry.cyou" "docker-cf.registry.cyou" "docker.actima.top" "docker.actima.top")

# 检测域名可用性的函数
check_host() {
    local host=$1
    echo "Checking availability of $host..."

    # 使用curl发送HTTP请求，检查HTTP响应码
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://$host)

    if [ "$response" -eq 200 ]; then
        echo "$host is available."
        return 0 # 返回0表示域名可用
    else
        echo "$host is not available."
        return 1 # 返回1表示域名不可用
    fi
}

proxy_host=""
for host in "${proxy_hosts[@]}"; do
    if check_host "$host"; then
        echo "Use host: $host"
        proxy_host=$host
        break
    fi
done

# 如果 proxy_host 是空的，退出脚本
if [ -z "$proxy_host" ]; then
    echo "No available proxy host found."
    exit 1
fi

set -ex
docker pull $proxy_host/$image_name
docker tag $proxy_host/$image_name $image_name
docker rmi $proxy_host/$image_name

set +ex
echo "Successfully pulled $image_name"
