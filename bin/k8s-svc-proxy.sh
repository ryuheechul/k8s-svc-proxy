#!/bin/bash
#bin/k8s-svc-proxy.sh __namespace__/__service__ 80:80

ns=""
svc=""
expose_port=""
target_port=""

tokenize() {
    IFS='/' read -ra ns_svc <<< "$1"

    ns=${ns_svc[0]}
    svc=${ns_svc[1]}

    IFS=':' read -ra ex_tar <<< "$2"

    expose_port=${ex_tar[0]}
    target_port=${ex_tar[1]}

    if [ -z "$ns" ] || [ -z "$svc" ] || [ -z "$expose_port" ] || [ -z "$target_port" ]; then
        echo "make sure you pass args like \$NAMESPACE/\$SERVICE \$EXPOSE_PORT:\$TARGET_PORT"
        return 1
    else
        return 0
    fi
}

verifyArgs() {
    if [ -z "$1" ] || [ -z "$2" ]; then # must have 2 args
        echo "must have 2 args!"
        return 1
    elif [ ! -z "$3" ]; then # not allowing third arg
        echo "third arg is not allowed!"
        return 1
    else
        return 0
    fi
}

verifyArgs $@
verifyResult=$?

tokenize $@
tokenizeResult=$?

if [ -z "$K8S_API_ENDPOINT" ]; then # must have 2 args
    echo "please provide \$K8S_API_ENDPOINT!"
    exit 1
elif [ $verifyResult -ne 0 ]; then # must have 2 args
    exit 1
elif [ $tokenizeResult -ne 0 ]; then # must have 2 args
    exit 1
else
    original="http://$K8S_API_ENDPOINT/api/v1/proxy/namespaces/$ns/services/$svc:$target_port/"
    echo "starting proxying $original to 0.0.0.0:$expose_port"
    container_name="${ns}_${svc}_${target_port}"
    docker rm $container_name 2> /dev/null
    docker run -it \
           --name "$container_name" \
           -p $expose_port:80 \
           -e "KUBE_SERVICE=$svc" -e "KUBE_NAMESPACE=$ns" -e "KUBE_TARGET_PORT=$target_port" \
           -e "KUBE_API_ENDPOINT=$K8S_API_ENDPOINT" \
           -v `pwd`/nginx-template.conf:/nginx-template.conf \
           -v `pwd`/bin/boot-nginx.sh:/boot-nginx.sh \
           nginx:latest /boot-nginx.sh
fi
