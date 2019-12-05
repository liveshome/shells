!/bin/bash
#删除用户-自动执行删除帐户的4个步骤
############
#定义函数
############
function get_answer {
#
unset ANSWER
ASK_COUNT=0
# 
while [ -z "$ANSWER" ]  #变量是否为空值
do
     ASK_COUNT=$[ $ASK_COUNT + 1 ]
#
     case $ASK_COUNT in
	 2)
	      echo
		  echo "Please answer the question."
		  echo
    ;;
	3)
	      echo
		  echo "One last try...plase answer the question."
		  echo
    ;;
	4)
	      echo
		  echo "Since you refuse to answer the question..."
		  echo "exiting program."
		  echo
		  #
		  exit
    ;;
	esac
#
    echo
#
    if [ -n "$LINE2" ]
	then
	     echo $LINE1
		 echo  -e $LINE2" \c"
	else
	     echo -e $LINE1" \c"
	fi
	#
	# 在超时前等待60秒回答
	  read -t 60 ANSWER
	done
	# 做一些可变的清理
	unset LINE1
	unset LINE2
	#
	}  #get_answer函数结束
    #
	##################
	function process_answer {
	#
	case $ANSWER in
	y|Y|YES|yes|Yes|yEs|yeS|YEs|yES )
	#如果用户回答“yes”，则不执行任何操作
	;;
	*) 如果用户回答“yes”，退出脚本”，退出脚本
	           echo
			   echo $EXIT_LINE1
			   echo $EXIT_LINE2
			   echo
			   exit
	;;
	esac
	#
	#  做一些可变的清理
	#
	unset EXIT_LINE1
	unset EXIT_LINE2
	#
	} #进程结束应答函数
    #
	############
	#函数结束定义
	#############主脚本####################
    #获取要检查的用户帐户的名称
    #
	echo "Step #1 - Determine User Account name to Delete"
	echo
	LINE1="Please enter the username of the user " 
	LINE2="account you wish to delete from system:" 
	get_answer 
	USER_ACCOUNT=$ANSWER 
    #
	#再次与脚本用户确认这是正确的用户帐户
    #
	
	LINE1="Is $USER_ACCOUNT the user account " 
	LINE2="you wish to delete from the system? [y/n]"
	get_answer
	#
	# 呼叫处理应答功能:
	# 如果用户回答“yes”，退出脚本
    #
	EXIT_LINE1="Because the account, $USER_ACCOUNT, is not " 
    EXIT_LINE2="the one you wish to delete, we are leaving the script..." 
	process_answer
	#
	################################
	# 检查用户帐户是否确实是系统上的帐户
    #
	USER_ACCOUNT_RECORD=$(cat /etc/passwd | grep -w $USER_ACCOUNT)
	#
	if [ $? -eq 1 ]  # 如果找不到帐号，退出脚本
	then
	     echo
		 echo "Account, $USER_ACCOUNT, not found. "
		 echo "Leaving the script...."
		 echo
		 exit
	fi
	#
	echo
	echo "I found this record:"
	echo $USER_ACCOUNT_RECORD
	#
	LINE1="Is this the correct User Account? [y/n]" 
	get_answer
	#
	#
	# 调用进程应答函数：
    # 如果用户回答“yes”，退出脚本
    EXIT_LINE1="Because the account, $USER_ACCOUNT, is not " 
    EXIT_LINE2="the one you wish to delete, we are leaving the script..." 
	process_answer
	#
	################################################################## 
    #	搜索属于用户帐户的任何正在运行的进程
	#
	echo
	echo "Step #2 - Find process on system belonging to user account"
	echo
	#
	ps -u $USER_ACCOUNT >/dev/null  #用户进程正在运行吗？
    #
	case $? in
	1)  # 没有为此用户帐户运行任何进程
	    #
		echo "There are no processes for this account currently running." 
		echo
    ;;
	0)  #正在为此用户帐户运行的进程。
        #询问脚本用户是否希望我们终止进程。
        #
		echo "USER_ACCOUNT has the following process running: "
		echo
		ps -u $USER_ACCOUNT
		#
		 LINE1="Would you like me to kill the process(es)? [y/n]" 
		 get_answer
		 #
		 case $ANSWER in
		  y|Y|YES|yes|Yes|yEs|yeS|YEs|yES )   #如果用户回答“yes”，
		                                      #终止用户帐户进程.
		  #
		  echo
		  echo "Killing off process(es)..."
		  #
		  #在变量COMMAND_1中列出运行代码的用户进程
          COMMAND_1="ps -u $USER_ACCOUNT --no-heading"
		  #创建命令以终止变量中的进程，COMMAND_3
          COMMAND_3="xargs -d \\n /usr/bin/sudo /bin/kill -9" 
		  # 
          #通过管道命令一起杀死进程
          $COMMAND_1 | gawk '{print $1}' | $COMMAND_3 
		  #
		  echo
		  echo "Process(es) Killed."
		 ;;
		 *)  #如果用户只回答“yes”，不要杀掉。
		      echo
			  echo "Will not Kill the process(es)"
              echo
         ;;
         esac
;;
esac
##################################################
# 创建用户帐户拥有的所有文件的报告
#
echo
echo "Step #3 - Find files on system belonging to user account"
echo
echo "Creating a report of all file owned by $USER_ACCOUNT."
echo
echo "It is recommended that you backup/archive these files." 
echo "and then do one of two things:"
echo " 1) Delete the files"
echo " 2) Change the files' ownership to a correct user account."
echo 
echo "Please wait. This may take a while..."
#
REPORT_DATE=$(date +%y%m%d)
REPORT_FILE=$USER_ACCOUNT"_Files_"$REPORT_DATE".rpt"
#
find / -user $USER_ACCOUNT > $REPORT_FILE 2>/dev/null
#
echo
echo "Report it complete."
echo "Name of report:  $REPORT_FILE"
echo "Location of report: $(pwd)"
echo
######################
# 删除用户帐户
echo
echo "Step #4 - Remove user account"
echo
#
LINE1="Remove $USER_ACCOUNT's account from system? [y/n]"
get_answer
#
#调用进程应答函数：
#如果用户只回答“yes”，退出脚本
#
EXIT_LINE1="Since you do not wish to remove the user account," 
EXIT_LINE2="$USER_ACCOUNT at this time, exiting the script..." 
process_answer 
#
userdel $USER_ACCOUNT          #delete user account 
echo
echo "User account, $USER_ACCOUNT, has been removed" 
echo
#
exit
