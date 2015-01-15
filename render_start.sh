#!/bin/bash

source $HOME/blender-render-script/render_lib.sh

count=1

for i in $HOME/to_be_rendered/*.blend; do
  gcloud compute --project "spartan-lacing-691" disks create \
    "blender-render-server-$count" --zone "us-central1-b" \
    --source-snapshot "blender-render-server-snap-05" \
    --type "pd-standard"

  gcloud compute --project "spartan-lacing-691" instances create \
    "blender-render-server-$count" --zone "us-central1-b" \
    --machine-type "n1-highcpu-16" --network "default" \
    --maintenance-policy "MIGRATE" \
    --scopes "https://www.googleapis.com/auth/compute" \
    "https://www.googleapis.com/auth/devstorage.full_control" \
    --disk "name=blender-render-server-$count" \
    "device-name=blender-render-server-$count" \
    "mode=rw" "boot=yes" "auto-delete=yes"

  gcloud compute config-ssh

  render_server=ubuntu@blender-render-server-$count.us-central1-b.\
    spartan-lacing-691

  ssh $render_server 'cd $HOME/blender-render-script/ && git pull origin master'

  scp $i $render_server:3D-Rot-me
  ssh $render_server 'at -f $HOME/blender-render-script/render_condition.sh now'
  mv $i $HOME/being_rendered
  count=$((count+1))
done
