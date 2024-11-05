declare awsumeprofiles
awsume() {
    # cache profiles
    if [ -z "$awsumeprofiles" ]; then
        awsumeprofiles=$(aws configure list-profiles)
    fi

    export AWS_PROFILE=$(echo "$awsumeprofiles" | fzf -1 -q "$*")
    echo "Switched to profile: $AWS_PROFILE"
}

ecsconnect() {
    printf '%-12s ' "Cluster:"
    cluster=$(aws ecs list-clusters --query 'clusterArns' | jq -r '.[]' | cut -d '/' -f2 | fzf -1 -q "$1")
    if [ -z "$cluster" ]; then
        echo "No cluster found"
        return
    fi
    echo $cluster

    printf '%-12s ' "Service:"
    service=$(aws ecs list-services --cluster $cluster --query 'serviceArns' | jq -r '.[]' | cut -d '/' -f3 | fzf -1 -q "$2")
    if [ -z "$service" ]; then
        echo "No service found"
        return
    fi
    echo $service

    printf '%-12s ' "Container:"
    taskDef=$(aws ecs describe-services --services $service --cluster $cluster | jq -r '.services[].taskDefinition')
    if [ -z "$taskDef" ]; then
        echo "No task definition found"
        return
    fi

    container=$(aws ecs describe-task-definition --task-definition $taskDef | jq -r '.taskDefinition.containerDefinitions[] | select(.linuxParameters.initProcessEnabled == true) | .name' | fzf -1 -q "$3")
    if [ -z "$container" ]; then
        echo "No container with SSM enabled found"
        return
    fi
    echo $container

    printf '%-12s ' "Task:"
    taskID=$(aws ecs list-tasks --cluster $cluster --service $service --query 'taskArns' | jq -r '.[]' | cut -d'/' -f3 | fzf -1 -q "$4")
    if [ -z "$taskID" ]; then
        echo "No task found"
        return
    fi
    echo $taskID

    echo "---"

    echo "connecting to $cluster/$service/$taskID/$container"

    aws ecs execute-command --interactive --command /bin/sh --task $taskID --cluster $cluster --container $container
}

ecr() {
    region=$(aws configure get region)
    aws ecr get-login-password --region $region |
        docker login \
            --password-stdin \
            --username AWS \
            "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$region.amazonaws.com"
}

ec2connect() {
    ec2name=$1
    targetHost=$2
    targetPort=$3
    localPort=$4

    instances=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType}" --filters Name=instance-state-name,Values=running --output text)
    instanceID=$(echo "$instances" | fzf -1 -q "$ec2name" | awk '{print $1}')

    if [ -z "$instanceID" ]; then
        echo "No instance selected"
        return
    fi

    if [ -n "$targetHost" ] && [ -n "$targetPort" ]; then
        if [ -z "$localPort" ]; then
            localPort=$3
        fi

        aws ssm start-session --target "$instanceID" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["'"$targetPort"'"],"localPortNumber":["'"$localPort"'"],"host":["'"$targetHost"'"]}'
    else
        aws ssm start-session --target "$instanceID"
    fi
}

cognito() {
    printf '%-14s ' "User Pool ID:"
    poolID=$(aws cognito-idp list-user-pools --max-results 50 --output text --query 'UserPools[].Id' | fzf -1)
    if [ -z "$poolID" ]; then
        exit 1
    fi
    echo $poolID

    usernames=$(aws cognito-idp list-users --user-pool-id "$poolID" --query "Users[].Username" --output json | jq -r '.[]')
    printf '%-14s ' "Username:"
    username=$(echo "$usernames" | fzf -1 -q "$1")
    if [ -z "$username" ]; then
        return
    fi
    echo $username

    availableGroups=$(aws cognito-idp list-groups --user-pool-id "$poolID" --output json --query "Groups[].GroupName" | jq -r '.[]')
    currentGroups=$(aws cognito-idp admin-list-groups-for-user --user-pool-id "$poolID" --username "$username" --output json --query "Groups[].GroupName" | jq -r '.[]')
    groups=$(echo "$availableGroups" | fzf --multi --preview-window="top:50%" --preview-label="Current groups" --preview "echo \"$currentGroups"\")
    if [ -z "$groups" ]; then
        return
    fi
    printf '%-14s ' "Groups:"

    echo

    diff --color=always -u <(echo "$currentGroups" | sort) <(echo "$groups" | sort) | tail -n +4

    echo

    read -r -q "REPLY?Continue? [y/N] "
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        return
    fi

    for g in $groups; do
        if [[ ! " ${currentGroups[*]} " =~ $g ]]; then
            echo "* Adding to $g"
            aws cognito-idp admin-add-user-to-group --user-pool-id "$poolID" --username "$username" --group-name "$g"
        fi
    done

    for g in $currentGroups; do
        if [[ ! " ${groups[*]} " =~ $g ]]; then
            echo "* Removing from $g"
            aws cognito-idp admin-remove-user-from-group --user-pool-id "$poolID" --username "$username" --group-name "$g"
        fi
    done
}
