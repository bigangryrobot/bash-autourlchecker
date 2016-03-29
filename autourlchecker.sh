#!/bin/bash
SetParam() {
export URLFILE="urllist"
export TIME=`date +%d-%m-%Y_%H.%M.%S`
SAFE_STATUSCODES=( 200 201 202 203 204 205 206 207 208 226 401 )
export STATUS_UP=`echo -e "[ RUNNING ]"`
export STATUS_DOWN=`echo -e "[ DOWN ]"`
export SCRIPT_LOG=`date '+%m%d%y'`.autoUrlCheckerReadable.log
export DIFF_LOG=`date '+%m%d%y'`.autoUrlCheckerDiff.log
}

URL_Status() {
SetParam
sed -i '/^$/d' $URLFILE; #Parse the URLFILE for removal of blank rows
cat $URLFILE | while read next
do
	DIFF_STATUS=""
	checkqa=$(echo $next|cut -d"|" -f2)

	if [ "$checkqa" = "TRUE" ];
	then
		  	urltobetested=$(echo $next|cut -d"|" -f1 | sed 's/https:\/\//https:\/\/qa./g')
	    	STATUS_CODE=`curl -k --max-time 120 --output /tmp/url.qa --silent --write-out '%{http_code}\n' $urltobetested`
	        #curl $urltobetested > /tmp/url.production
     		#qaurltobetested=$(echo $urltobetested | sed 's/https:\/\//https:\/\/qa./g')
	        #curl -k $qaurltobetested > /tmp/url.qa
	        ## sanitize files
	        sed -i '/time/d' /tmp/url.qa
	        sed -i '/time/d' /tmp/url.prod
	    if diff /tmp/url.prod /tmp/url.qa >/dev/null ;
		  then
		    DIFF_STATUS=`echo -e "[ SAME ]"`
		  else
		    DIFF_STATUS=`echo -e "[ DIFF ]"`
		    echo "-----------------------------------------------------------------------" >> $DIFF_LOG
		    echo "-----------------------------------------------------------------------" >> $DIFF_LOG
		    echo "START DIFF OF "$urltobetested >> $DIFF_LOG
		    sdiff --suppress-common-lines -i -b /tmp/url.prod /tmp/url.qa >> $DIFF_LOG
		    echo "END DIFF OF "$urltobetested >> $DIFF_LOG
		    echo "-----------------------------------------------------------------------" >> $DIFF_LOG
		    echo "-----------------------------------------------------------------------" >> $DIFF_LOG
   	        rm '/tmp/url.prod'
	        rm '/tmp/url.qa'
		fi;
    		ECHO_STATUS $STATUS_CODE		
    fi
    urltobetested=$(echo $next|cut -d"|" -f1)
	STATUS_CODE=`curl --max-time 120 --output /tmp/url.prod --silent --write-out '%{http_code}\n' $urltobetested`
    ECHO_STATUS $STATUS_CODE	
done;
}

ECHO_STATUS() {
	case $STATUS_CODE in
		100) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Continue" ;;
		101) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Switching Protocols" ;;
		102) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Processing (WebDAV) (RFC 2518) " ;;
		103) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Checkpoint" ;;
		122) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Request-URI too long" ;;
		200) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : OK" ;;
		201) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Created" ;;
		202) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Accepted" ;;
		203) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Non-Authoritative Information" ;;
		204) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : No Content" ;;
		205) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Reset Content" ;;
		206) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Partial Content" ;;
		207) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Multi-Status (WebDAV) (RFC 4918) " ;;
		208) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Already Reported (WebDAV) (RFC 5842) " ;;
		226) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : IM Used (RFC 3229) " ;;
		300) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Multiple Choices" ;;
		301) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Moved Permanently" ;;
		302) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Found" ;;
		303) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : See Other" ;;
		304) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Not Modified" ;;
		305) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Use Proxy" ;;
		306) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Switch Proxy" ;;
		307) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Temporary Redirect (since HTTP/1.1)" ;;
		308) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Resume Incomplete" ;;
		400) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Bad Request" ;;
		401) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Unauthorized" ;;
		402) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Payment Required" ;;
		403) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Forbidden" ;;
		404) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Not Found" ;;
		405) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Method Not Allowed" ;;
		406) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Not Acceptable" ;;
		407) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Proxy Authentication Required" ;;
		408) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Request Timeout" ;;
		409) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Conflict" ;;
		410) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Gone" ;;
		411) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Length Required" ;;
		412) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Precondition Failed" ;;
		413) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Request Entity Too Large" ;;
		414) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Request-URI Too Long" ;;
		415) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Unsupported Media Type" ;;
		416) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Requested Range Not Satisfiable" ;;
		417) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Expectation Failed" ;;
		500) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Internal Server Error" ;;
		501) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Not Implemented" ;;
		502) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Bad Gateway" ;;
		503) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Service Unavailable" ;;
		504) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : Gateway Timeout" ;;
		505) echo "At $TIME: $urltobetested url status returned $STATUS_CODE : HTTP Version Not Supported" ;;
	esac
	URL_SafeStatus $STATUS_CODE
}

URL_SafeStatus() {
flag=0
for safestatus in ${SAFE_STATUSCODES[@]}
	do
		#echo "got Value of STATUS CODE= $1";
		#echo "Reading Safe Code= $safestatus";
		if [ $1 -eq $safestatus ]; then
			if [ "$checkqa" = "FALSE" ]; then
			        echo "At $TIME: Status Of  URL $urltobetested = $STATUS_UP" ;
			        flag=1
			        break;
			fi
			else 				
		        echo "At $TIME: Status Of  URL $urltobetested = $STATUS_UP and $DIFF_STATUS" ;
		        flag=1
			    break;		        
		fi	
	done

	if [ $flag -ne 1 ] ; then
		echo "At $TIME: Status Of  URL $urltobetested = $STATUS_DOWN";
		#break;
	fi
}

SetParam
URL_Status | tee -a $SCRIPT_LOG
