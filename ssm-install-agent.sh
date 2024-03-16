#!/bin/bash

my_profile=demo
script_file='installCodeDeployLinuxAgent.json'
FILENAME="instances_linux.txt"

# Build output filename with date
now=$(date +"%m%d%Y")
outfile=$(echo "linux_agent_install_status_${now}.csv")
# Write the headers
echo "InstanceId, Status, Output" > $outfile


# Read through the instances in the file
LINES=$(cat $FILENAME)
for LINE in $LINES; do
  echo $LINE
  # Run a bash script in a JSON file
  sh_command_id=$(aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --targets "Key=InstanceIds,Values=${LINE}" \
    --cli-input-json file://$script_file \
    --output text \
    --query "Command.CommandId" \
    --profile $my_profile)
  echo $sh_command_id
  
  # Wait for command to be finished
  aws ssm wait command-executed --command-id $sh_command_id --instance-id ${LINE} --profile $my_profile
  
  # Get the status of the command
  status=$(aws ssm list-command-invocations \
    --command-id $sh_command_id \
    --profile $my_profile \
    --details \
    --output text \
    --query "CommandInvocations[].CommandPlugins[].Status")
   echo $status
  
  # Get the output of the command
  output=$(aws ssm list-command-invocations \
    --command-id $sh_command_id \
    --profile $my_profile \
    --details \
    --output text \
    --query "CommandInvocations[].CommandPlugins[].Output")
   echo $output 
   echo "$LINE,$status,$output" >> $outfile
done
