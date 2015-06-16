#!/bin/bash

count=8

for i in $HOME/to_be_rendered/*.blend; do
  gcloud compute --project "spartan-lacing-691" disks create \
    "blender-render-server-$count" --zone "us-central1-b" \
    --source-snapshot "blender-render-server-snap-06" \
    --type "pd-standard"

  gcloud compute --project "spartan-lacing-691" instances create \
    "blender-render-server-$count" --zone "us-central1-b" \
    --machine-type "n1-highcpu-32" --network "default" \
    --maintenance-policy "MIGRATE" \
    --scopes "https://www.googleapis.com/auth/compute" \
    "https://www.googleapis.com/auth/devstorage.full_control" \
    --disk "name=blender-render-server-$count" \
    "device-name=blender-render-server-$count" \
    "mode=rw" "boot=yes" "auto-delete=yes"

  sleep 120
  gcloud compute config-ssh

  render_server=ubuntu@blender-render-server-$count.us-central1-b.spartan-lacing-691

<<<<<<< HEAD
  ssh $render_server "cd \$HOME/blender-render-script/ && git pull origin solar-${count}"
=======
  ssh $render_server "cd \$HOME/blender-render-script/ && git pull origin solar-$count"
>>>>>>> be49c79f250227e3b96947c27cdc54f6d42ba7f2
  if [[ $i != "$HOME/to_be_rendered/*.blend" ]]; then
    scp $i $render_server:$HOME/3D-Rot-me
    echo "$(date) Copied file to server. Commence render_conditions" >> $HOME/log.txt
    ssh $render_server 'at -f $HOME/blender-render-script/render_condition.sh now'
    mv $i $HOME/being_rendered
    count=$((count+1))
  else
    echo "$(date) Blend file not found. Deleting render server instance." >> $HOME/log.txt
    gcloud compute instances delete blender-render-server-$count --quiet --zone "us-central1-b"
  fi
done
