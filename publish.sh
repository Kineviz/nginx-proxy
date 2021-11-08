#!/usr/bin/env bash

USAGE='Usage: $0 {build|release|arm|letsencrypt} 
eg. 
release : build ./Dockerfile to code4demo/nginx-proxy:latest  
'
CURRENTPATH=$(dirname ${0})
SHELLNAME=$(echo "$0" | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')
#support in -s 
if [ -L "$0" ] ; then 
SHELLPATH=$(echo $(ls -l "$CURRENTPATH"  | grep "$SHELLNAME") | awk  -F "->" '{print $NF}') 
#SHELLNAME=$(echo $SHELLPATH | awk -F "/" '{print $NF}')
fi

PORJECTNAME="nginx-proxy"
DOCKERHOST="kineviz" 
if [ -z "$2" ]; then
    echo "Default docker registry host : $DOCKERHOST "
else
DOCKERHOST=$2
    echo "Read the docker registry host : $DOCKERHOST "
fi

build(){
    cd "${CURRENTPATH}"
    if [ ! -f "${CURRENTPATH}/Dockerfile.alpine" ]; then 
        echo "Can't found ./Dockerfile.alpine file"
        exit 1
    else 
        docker build \
        --build-arg http_proxy=${http_proxy} \
        --build-arg https_proxy=${https_proxy} \
        -f ./Dockerfile.alpine  -t "${DOCKERHOST}/${PORJECTNAME}:latest" ./ 
    fi
}

docker_push_release(){
    echo "will push docker image ${DOCKERHOST}/${PORJECTNAME}:latest to ${DOCKERHOST}"
    docker push "${DOCKERHOST}/${PORJECTNAME}:latest"
}


build_arm(){
    cd "${CURRENTPATH}"
    if [ ! -f "${CURRENTPATH}/Dockerfile.arm" ]; then 
        echo "Can't found ./Dockerfile.arm file"
        exit 1
    else 
        docker build \
        --build-arg http_proxy=${http_proxy} \
        --build-arg https_proxy=${https_proxy} \
        --platform=linux/arm64 \
        -f ./Dockerfile.arm  -t "${DOCKERHOST}/${PORJECTNAME}:arm" ./  
    fi
}

 docker_push_release_arm(){
    echo "will push docker image ${DOCKERHOST}/${PORJECTNAME}:arm to ${DOCKERHOST}"
    docker push "${DOCKERHOST}/${PORJECTNAME}:arm"
}


build_letsencrypt(){
    cd "${CURRENTPATH}"
    if [ ! -f "${CURRENTPATH}/Dockerfile.letsencrypt" ]; then 
    echo "Can't found ./Dockerfile.letsencrypt file"
    exit 1
    else 
        docker build \
        --build-arg http_proxy=${http_proxy} \
        --build-arg https_proxy=${https_proxy} \
        -f ./Dockerfile.letsencrypt  \
        -t "${PORJECTNAME}:letsencrypt" ./  
    fi
}

 docker_push_release_letsencrypt(){
    echo "will push docker image ${PORJECTNAME}:letsencrypt to ${DOCKERHOST}"
    docker tag  "${PORJECTNAME}:letsencrypt" "${DOCKERHOST}/${PORJECTNAME}:letsencrypt"
    docker push "${DOCKERHOST}/${PORJECTNAME}:letsencrypt"
}


clean(){
    ## clean un-use docker images & volumes
    docker image prune -a --force --filter "until=240h" && docker system prune --volumes --force
}


run() {

  case "$1" in
    clean)
    clean
        ;;
    build)
    build
        ;;
    release_arm)
    build_arm 
    docker_push_release_arm 
    ;;
    release_letsencrypt)
    build_letsencrypt
    docker_push_release_letsencrypt
    ;;
    release)
    build
    docker_push_release
    ;;
    *)
        echo "$USAGE"
     ;;
esac

exit 0;

}

if [ -z "$1" ]; then
    echo "$USAGE"
    exit 0
fi

run "$1"
## already clean un-use docker image & volumes
clean