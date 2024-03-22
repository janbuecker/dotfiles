cdp() {
  cd $(~/bin/dir_select "$@")
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

ecsexec() {
  if [ "$1" = "" ]; then
    echo "missing version"
    return
  fi
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

  taskID=$(aws ecs list-tasks --cluster shopware-application --service-name $serviceName-$1 | jq '.taskArns[]' -r | cut -d'/' -f3 | fzf)
  aws ecs execute-command --interactive --command /bin/bash --task $taskID --cluster shopware-application --container $containerName
}

ecr() {
  region=$(aws configure get region)
  aws ecr get-login-password --region $region |
    docker login \
      --password-stdin \
      --username AWS \
      "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$region.amazonaws.com"
}

mfa() {
  _code=$(ykman oath accounts code | fzf -1 -q "$1" | awk '{print $NF}')
  echo -n $_code
  echo $_code | pbcopy
}

declare awsumeprofiles
awsume() {
  # cache profiles
  if [ -z "$awsumeprofiles" ]; then
    awsumeprofiles=$(aws configure list-profiles)
  fi

  export AWS_PROFILE=$(echo "$awsumeprofiles" | fzf -1 -q "$*")
  echo "Switched to profile: $AWS_PROFILE"
}

ec2connect() {
  instances=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType}" --filters Name=instance-state-name,Values=running --output text)
  instanceID=$(echo "$instances" | fzf -1 -q "$*" | awk '{print $1}')

  if [ -z "$instanceID" ]; then
    echo "No instance selected"
    return
  fi

  aws ssm start-session --target "$instanceID"
}
