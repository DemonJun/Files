#!/usr/bin/env bash
set -e

image_name=$1
proxy_hosts=("dockerpull.com" "docker.1panel.live" "m.daocloud.io")
other_mirrors=("elastic.co" "gcr.io" "ghcr.io" "k8s.io" "microsoft.com" "nvcr.io" "quay.io")

# 如果传入参数为空，退出
if [ -z "$image_name" ]; then
    echo "No image_name found"
    exit 1
else
    for mirror in "${other_mirrors[@]}"; do
        if [[ "$image_name" == *"$mirror"* ]]; then
            echo "image need pull from $mirror, use proxy m.daocloud.io"
            proxy_hosts=("m.daocloud.io")
            break
        fi
    done
fi

for proxy_host in "${proxy_hosts[@]}"; do
    echo "docker pull $proxy_host/$image_name"

    docker pull $proxy_host/$image_name
    if [ $? -eq 0 ]; then
        break
    fi
done

set -x
docker tag $proxy_host/$image_name $image_name
docker rmi $proxy_host/$image_name

set +x
echo "Successfully pulled $image_name"
