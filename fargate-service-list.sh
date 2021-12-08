#!/bin/bash

cluster_arns=(`aws ecs list-clusters --output text --query "clusterArns[]"`)
selected_cluster_index=0
while [[ $selected_cluster_index -le 0 || $selected_cluster_index -gt ${#cluster_arns[@]} ]]; do
  index=0
  for cluster in ${cluster_arns[@]}; do
    index=$((1 + $index))
    name=`echo $cluster | rev | cut -d'/' -f1 | rev`
    echo "$index .) $name"
  done
  read -p "Select a cluster $> " selected_cluster_index
done
selected_cluster_index=$(($selected_cluster_index - 1))
selected_cluster_name=`echo ${cluster_arns[$selected_cluster_index]} | rev |cut -d'/' -f1 | rev`

service_arns=(`aws ecs list-services --cluster ${cluster_arns[$selected_cluster_index]} --output=text --query=serviceArns[]`)
selected_service_index=0
while [[ $selected_service_index -le 0 || $selected_service_index -gt ${#service_arns[@]} ]]; do
  index=0
  for service in ${service_arns[@]}; do
    index=$((1 + $index))
    name=`echo $service | rev | cut -d'/' -f1 | rev`
    echo "$index .) $name"
  done
  read -p "Select a service $> " selected_service_index
done
selected_service_index=$(($selected_service_index - 1))
selected_service_name=`echo ${service_arns[$selected_service_index]} | rev |cut -d'/' -f1 | rev`

echo "Service: ${selected_service_name}"
task_arns=(`aws ecs list-tasks --cluster ${cluster_arns[$selected_cluster_index]} --service ${service_arns[$selected_service_index]} --output=text --query=taskArns[]`)
echo -n "Tasks:   "
for task in ${task_arns[@]}; do
  name=`echo $task | rev | cut -d'/' -f1 | rev`
  echo -n "$name "
done
echo ""
selected_task_id=`echo ${task_arns[0]} | rev | cut -d'/' -f1 | rev`

echo "Example Exec Commands:"
echo ""
containers=(`aws ecs describe-tasks --cluster ${cluster_arns[$selected_cluster_index]} --task $selected_task_id --output=text --query tasks[].containers[].name`)
for container in ${containers[@]}; do
  echo "  aws ecs execute-command --interactive --cluster $selected_cluster_name \\"
  echo "    --task $selected_task_id --container $container --command '/bin/bash'"
  echo ""
done

