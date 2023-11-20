cdp() {
	cd $(~/bin/dir_select "$@")
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
		exit 1
	fi

	aws ssm start-session --target "$instanceID"
}
