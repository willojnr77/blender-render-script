#!/bin/sh

source $HOME/blender-render-script/render_lib.sh

gcloud compute config-ssh

for i in $HOME/3D-Rot-me/*.blend; do
  j=basename $i .blend
  echo "$(date) blender is running..." >> blender_running.txt
  while [$next_frame -lt $end_frame];do
    blender -b $(basename $i) -o $HOME/3D-Rot-me/$j/jpg/#.jpg\
    -E CYCLES -F JPG -s $next_frame -e $end_frame -a
    next_frame=basename $(ls -1 $HOME/3D-Rot-me/$j/jpg | sort -g | tail -1) \
      .jpg
    if [$attempt -ge $limit]; then
      ssh $director_server 'echo "$(date) Something is not right. Check .blend file" >> log.txt'
      ssh $director_server 'mv $HOME/being_rendered/$j.blend $HOME/not_rendered'
      break
    elif [$next_frame -ge $end_frame]
      ...
    fi

  done
done


