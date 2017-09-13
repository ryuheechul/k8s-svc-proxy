#!/bin/bash

envsubst < /nginx-template.conf '$$KUBE_API_ENDPOINT $$KUBE_SERVICE $$KUBE_NAMESPACE $$KUBE_TARGET_PORT $$KUBE_EXPOSE_PORT' > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
