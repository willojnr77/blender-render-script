#!/bin/sh
#replace with python. Script is over 20 lines.
source $HOME/blender-render-script/render_lib.sh
render_server=$HOSTNAME
gcloud compute config-ssh

for i in $HOME/3D-Rot-me/*.blend; do
  j=basename $i .blend
  echo "$(date) blender is running..." >> blender_running.txt
  while [ $next_frame -lt $end_frame ]; do
    blender -b $(basename $i) -o $HOME/3D-Rot-$j/jpg/#.jpg\
    -E CYCLES -F JPG -s $next_frame -e $end_frame -a
    next_frame=basename $(ls -1 $HOME/3D-Rot-$j/jpg | sort -g | tail -1) \
      .jpg
    attempt=$((attempt+1))
    if [$attempt -gt $limit]; then
      ssh $director_server 'echo "$(date) Something is not right. \
        Check .blend file" >> $HOME/log.txt'
      ssh $director_server 'mv $HOME/being_rendered/$j.blend \
        $HOME/not_rendered'
      break
    else
      ssh $director_server 'echo "$(date) Render was interrupted. Attempt \
        no. $attempt" >> $HOME/log.txt'
    fi
  done
  ssh $director_server 'echo "$(date) Render successful." >> $HOME/log.txt'
  ssh $director_server 'mv $HOME/being_rendered $HOME/rendered'
  ssh $director_server 'mkdir -p $HOME/rendered_images/3D-Rot-$j/jpg'
  scp $HOME/3D-Rot-$j/jpg $director_server:$HOME/rendered_images/\
    3D-Rot-$j/jpg
done
#shutdown sequence
ssh $director_server 'echo "$(date) Shutting down $render_server." \
  >> $HOME/log.txt'
ssh $director_server 'gcloud compute instances delete $render_server'
