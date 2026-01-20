#!/usr/bin/env bash
set -e

image_name=$1
architecture=${2:-amd}
proxy_hosts=("docker.1ms.run" "docker.1panel.live" "docker.ketches.cn" "m.daocloud.io")
other_mirrors=("elastic.co" "gcr.io" "ghcr.io" "k8s.io" "microsoft.com" "nvcr.io" "quay.io")

# 设置架构参数
case "$architecture" in
"amd")
	arch_flag="--platform linux/amd64"
	;;
"arm")
	arch_flag="--platform linux/arm64"
	;;
"")
	arch_flag=""
	;;
*)
	echo "Invalid architecture: $architecture. Use 'amd' for amd64 or 'arm' for arm64"
	exit 1
	;;
esac

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
	echo "docker pull $arch_flag $proxy_host/$image_name"

	docker pull $arch_flag $proxy_host/$image_name
	if [ $? -eq 0 ]; then
		break
	fi
done

set -x
docker tag $proxy_host/$image_name $image_name
docker rmi $proxy_host/$image_name

set +x
echo "Successfully pulled $image_name"
