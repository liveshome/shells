#!/bin/bash
user=用户1
user2=用户2
passwd1=密码1
passwd2=密码2
for  ip in  机器ip
do
case $ip in    
182 | 108 )                         #筛选出不能关机的ip
        echo $ip pass ;;
* )
     if  ipmitool -I lanplus -H 192.168.1.$ip -U $user -P $passwd1  power off      #套用用户1的账号密码关机
then
       echo  $ip ok
elif   ipmitool -I lanplus -H 192.168.1.$ip -U $user2 -P  $passwd2  power off       #套用用户2的账号密码关机
then
       echo  $ip ok                                    
else
   echo no $ip ip                    #没有这些机器的ip
fi
;;
esac
done 2>> err 1>>poweroff              #错误追加到err文件，正确追加到poweroff文件
