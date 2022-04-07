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

awsp () {
    if [[ $# -gt 0 ]]; then
        profile=$(aws configure list-profiles | fzf -1 -0 --query="$1 $2 $3")
    else
        profile=$(aws configure list-profiles | fzf)
    fi

    if [ -z "$profile" ]; then
        return
    fi

    # Clear out existing AWS session environment, or the awscli call will fail
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN

    export AWS_PROFILE=$profile

    if [ "$AWS_PROFILE" = "default" ]; then
        RES=$(aws sts get-session-token --profile default)
    else
        RES=$(aws sts assume-role --role-arn $(aws configure get role_arn --profile ${AWS_PROFILE}) --role-session-name=sess-${AWS_PROFILE})
    fi

    export AWS_ACCESS_KEY_ID=$(echo $RES | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $RES | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $RES | jq -r .Credentials.SessionToken)
}
