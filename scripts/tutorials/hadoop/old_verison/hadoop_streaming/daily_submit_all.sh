#!/bin/bash
#Author: fsrm

# get date param
if [[ $# == 0 ]];then
    data_date=$(date +%F -d '-1 days')
else
    data_date=${@:1:1}
fi
MSG_ID=""
JOB_NAME="fsrm__mr__streaming_$data_date"

# config env
HADOOP_PATH=/usr/bin/hadoop/software/hadoop/bin:/usr/bin/hadoop/software/hadoop/etc/hadoop
export PATH=$PATH:$HADOOP_PATH
source ~/.bashrc

# get code path & log path
cwd_path=$(dirname `readlink -f $0`)
logs_path=${cwd_path}/logs
log_prefix=${data_date}

# make dir & clear current log
mkdir -p ${logs_path}
cd ${cwd_path}
if [ -a "$(ls ${logs_path}/${log_prefix}* 2>/dev/null)"  ]; then
    rm ${logs_path}/${log_prefix}*
fi

# execute 
echo "[*] `date` $JOB_NAME started."
cmd_list="1_/daily_submit.sh 2_/daily_submit.sh"
flag=0
for cmd in $cmd_list:
do
    sh -x $cmd ${data_date} 1>>${logs_path}/${log_prefix}_${cmd}.out 2>>${logs_path}/${log_prefix}_${cmd}.err
    if [[ $? -ne 0 ]]; then
        flag=1
        echo "$cmd job error"
    fi
done

# check submit state & log
if [[ $flag -ne 0 ]]; then
    trace_url=`cat ${logs_path}/${data_date}.err | grep url | awk -F 'http' '{print "http"$2}'`
    cat ${logs_path}/${data_date}.* > ${logs_path}/${log_prefix}_ERROR
    echo -e "\nTrace url:\c ${trace_url}" >> ${logs_path}/${log_prefix}_ERROR
    echo "[*] `date` $JOB_NAME failed."
    _syslog $MSG_ID "[mail subject=\"$JOB_NAME failed\"]" "$trace_url"
else
    echo "[*] `date` $JOB_NAME successed."
    #_syslog $MSG_ID "[mail subject=\"$JOB_NAME successed.\"]" "."
fi
