#!/bin/bash 
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

#CONFIGURE FOR YOUR NEEDS
FULLPATH=/var/bin/ServiceCheck
FILEPATH=$FULLPATH/services/*.serv

#DO NOT MODIFY BELOW
function CheckIfRunning {
    #echo Parameter1: $1 
    #echo Parameter2: $2
    
    currenttime=`date +%Y-%m-%d/%H:%M:%S`
    if ps ax | grep -v grep | grep $1 > /dev/null
    then
	echo "($currenttime) NOTICE: $1 service is running"
	if [[ -s $FULLPATH/services/$1.check ]] ; then
	    #Corresponding check file has data, try to run it
	    echo "Additional checks mandatory for $1"
	    $FULLPATH/services/$1.check
	else
	echo "($currenttime) NOTICE: $1 passed checks and  is running"
	fi ;	
    else
	logger -s  "($currenttime) ERROR:  $1 is not running"
	#try to run the serv file to do the necessary corrections
	if [[ -s $2 ]] ; then
	    #Corresponding serv file has data, try to run it
	    $FULLPATH/services/$1.serv
	else
	    #Corresponding serv file is empty, try to restart the service
	    systemctl restart $1
	fi ;
    fi
}  

cd $FULLPATH
for filename in $FILEPATH
do
    #echo "Parsing $filename"
    ext=${filename##*.}
    temp=`basename $filename $ext`
    #get rid of leading .
    SERVICENAME=${temp%.}
    #echo Checking Service: $SERVICENAME    
    CheckIfRunning $SERVICENAME $filename
done;



