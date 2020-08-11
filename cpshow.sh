#!/bin/bash

h1=$(du -sh /home/home.tar.gz | sed -n 's/G//p'  | awk '{print $1}')
i=1	 
h=$( du -sh /mnt/usb/bf/home.tar.gz |  sed -n 's/G//p' | awk '{print $1}' )
while [  $h -le $h1  ]
do
	h=$( du -sh /mnt/usb/bf/home.tar.gz |  sed -n 's/G//p' | awk '{print $1}' )
        s=$[ $h1 - $h ]
	sleep 1
	echo 当前进度是$h G,剩余$s G.
	let i++
done
echo 拷贝完成

