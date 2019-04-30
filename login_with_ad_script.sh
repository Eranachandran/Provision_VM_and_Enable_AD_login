#!/bin/bash
login_username=$1;
login_password=$2;
resource_group=$3;
vm_name=$4;
iam_username=$5;

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
sudo tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get -y update
sudo apt-get -y install apt-transport-https azure-cli
dpkg -l |grep "aadlogin"
status=$?
	if [[ $status -ne "0" ]]; then
		az login -u $login_username -p $login_password
        	az vm extension set \
        	--publisher Microsoft.Azure.ActiveDirectory.LinuxSSH \
        	--name AADLoginForLinux \
        	--resource-group $resource_group \
        	--vm-name $vm_name
		vm=$(az vm show --resource-group $resource_group --name $vm_name --query id -o tsv)
		az role assignment create \
    			--role "Virtual Machine Administrator Login" \
   			--assignee $iam_username \
    			--scope $vm
	else
		az login -u $login_username -p $login_password	
		vm=$(az vm show --resource-group $resource_group --name $vm_name --query id -o tsv)
		az role assignment create \
    			--role "Virtual Machine Administrator Login" \
   			--assignee $iam_username \
    			--scope $vm
