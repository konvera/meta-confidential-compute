#!/bin/bash
set -e

# Check if 'az' exists
if ! command -v az &> /dev/null; then
    echo "Error: 'az' command not found. Please install the Azure CLI."
    exit 1
fi

# Check if 'azcopy' exists
if ! command -v azcopy &> /dev/null; then
    echo "Error: 'azcopy' command not found. Please install AzCopy."
    exit 1
fi

# Check if 'jq' exists
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Please install jq."
    exit 1
fi

# example usage: ./deploy.sh /path/to/disk.vhd disk_and_vm_name resource_group region Standard_EC4eds_v5

DISK_PATH=$1
DISK_NAME=$2
RESOURCE_GROUP=$3
REGION=$4
VM_SIZE=$5

DISK_SIZE=`wc -c < ${DISK_PATH}`

echo "creating disk"
az disk create -n ${DISK_NAME} -g ${RESOURCE_GROUP} -l ${REGION} --os-type Linux --upload-type Upload --upload-size-bytes ${DISK_SIZE} --sku standard_lrs --security-type ConfidentialVM_NonPersistedTPM --hyper-v-generation V2

echo "granting access"
SAS_REQ=`az disk grant-access -n ${DISK_NAME} -g ${RESOURCE_GROUP} --access-level Write --duration-in-seconds 86400`
echo ${SAS_REQ}
SAS_URI=`echo ${SAS_REQ} | jq -r '.accessSas'`

echo "copying disk"
azcopy copy ${DISK_PATH} ${SAS_URI} --blob-type PageBlob

echo "revoking access"
az disk revoke-access -n ${DISK_NAME} -g ${RESOURCE_GROUP}

echo "booting vm"
az vm create --name ${DISK_NAME} --size ${VM_SIZE} --resource-group ${RESOURCE_GROUP} --attach-os-disk ${DISK_NAME} --security-type ConfidentialVM --enable-vtpm true --enable-secure-boot false  --os-disk-security-encryption-type NonPersistedTPM --os-type Linux
