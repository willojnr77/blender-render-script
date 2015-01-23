#!/bin/bash
#replace with python. Script is over 20 lines.
director_server=ubuntu@blender-director.us-central1-b.spartan-lacing-691
next_frame=1
end_frame=30
attempt=0
limit=2

gcloud compute config-ssh

for i in $(ls $HOME/3D-Rot-me/*.blend); do
  j=$(basename $i .blend)
  while [ $next_frame -lt $end_frame ]; do
    ssh $director_server "echo \"$(date) Blender is running...\" \
      >> $HOME/log.txt"
    blender -b $HOME/3D-Rot-me/$j.blend -o $HOME/3D-Rot-$j/jpg/#.jpg -E CYCLES \
      -F JPG -s $next_frame -e $end_frame -a
    next_frame=$(basename $(ls -1 $HOME/3D-Rot-$j/jpg | sort -g | tail -1) \
      .jpg)
    ssh $director_server "echo \"$(date) Blender stopped...\" \
      >> $HOME/log.txt"
    attempt=$((attempt+1))
    if [ $attempt -gt $limit ]; then
      ssh $director_server "echo '$(date) Something is not right. \
        Check .blend file' >> $HOME/log.txt"
      ssh $director_server "mv $HOME/being_rendered/$j.blend \
        $HOME/not_rendered"
      break
    elif [ $next_frame -ge $end_frame ]; then
      ssh $director_server "echo \"$(date) Render successful.\" >> $HOME/log.txt"
      ssh $director_server "mv $HOME/being_rendered/$j.blend $HOME/rendered"
      ssh $director_server "mkdir -p $HOME/rendered_images/"
      scp -r $HOME/3D-Rot-$j $director_server:rendered_images
      break
    else
      ssh $director_server "echo \"$(date) Render has stopped. Checking \
        if things are OK. Attempt no. $attempt\" >> $HOME/log.txt"
    fi
  done
done
#shutdown sequence
ssh $director_server "echo \"$(date) Shutting down $HOSTNAME .\" >> $HOME/log.txt"
ssh $director_server "gcloud compute instances delete $HOSTNAME"
