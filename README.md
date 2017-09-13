# k8s-svc-proxy
> Give you a tunnel for you to easily access your k8s service on your local machine

> Powered by Docker, kubectl, Nginx and Shell scripts

## Motivations
- To make your life easier!
- Testing k8s services on local machines is not so easy especially when you access them via browser because all the relative path will not work since your service url through `kube proxy` is not a root level.

## Requirement

- For now, you need to clone this source to use the feature
- It works as a Docker container, so we need your machine to have a Docker installed and running
- You need to have running `kube proxy` accepting any host just like below
> `$ kubectl proxy --address 0.0.0.0 --accept-hosts '.*'`
- It needs `K8S_API_ENDPOINT` env var pointing kubectl proxy


## Run

`$ bin/ksp [namespace]/[service] [expose_port]:[target_port]`

### Example
```shell
$ kubectl proxy --address 0.0.0.0 --accept-hosts '.*' # if not running yet
$ # `curl 0.0.0.0:8001` and it should work if your k8s cluster set up correctly
$ export K8S_API_ENDPOINT=docker.for.mac.localhost:8001 # if you are using mac and docker version is higher than 17.06
$ # Make sure you cloned this repository and you are in the directory
$ bin/ksp default/my-service 3000:80
```
> It expose http://docker.for.mac.localhost:8001/api/v1/proxy/namespaces/default/services/my-service:80/ to 0.0.0.0:3000

> Go ahead and try `curl localhost:3000`

## FYI
- Since it works as a container and the network mode is bridge mode, you can't give `localhost nor 0.0.0.0` to `K8S_API_ENDPOINT`
- Give the specific ip address of your machine like 192.\*.\*.\* or 10.\*.\*.\*
- Or just simply use `docker.for.mac.localhost` or `docker.for.win.localhost` if you use docker later than 17.06
