cdp () {
    cd $(~/bin/dir_select "$@");
}

ecsexec () {
    if [ "$1" = "" ]; then echo "missing version"; return; fi
    if [ "$2" = "fpm" ]; then
        containerName=fpm
        serviceName=shopware
    elif [ "$2" = "nginx" ]; then
        containerName=nginx
        serviceName=shopware
    elif [ "$2" = "kraftwork" ]; then
        containerName=kraftwork
        serviceName=kraftwork
    else
        echo "invalid target - kraftwork or fpm"
        return
    fi

    taskID=$(aws ecs list-tasks --cluster shopware-application --service-name $serviceName-$1 | jq '.taskArns[0]' -r | cut -d'/' -f3)
    aws ecs execute-command --interactive --command /bin/bash --task $taskID --cluster shopware-application --container $containerName
}

ecr() {
  region=$(aws configure get region)
  aws ecr get-login-password --region $region \
    | docker login \
        --password-stdin \
        --username AWS \
        "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$region.amazonaws.com"
}
