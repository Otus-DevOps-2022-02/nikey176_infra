#!/bin/bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-family=reddit-full,size=10GB \
  --network-interface subnet-name=infra-ru-central1-a,nat-ip-version=ipv4,nat-address=51.250.70.70 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=../packer/files/metadata_reddit_vm.yaml
