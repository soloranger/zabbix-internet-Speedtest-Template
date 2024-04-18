ABBIX_DATA=/tmp/speedtest-zabbix.tmp
FILE=/tmp/result.json


while getopts s:f: flag
do
    case "${flag}" in
        s) server=${OPTARG};;
        f) format=${OPTARG};;
    esac
done

#RUN Speedtest
echo "Speedtest has been Started"
speedtest --server-id=$server --format=json >> $FILE

#Calculateing data"
output=$(cat $FILE)
Download=$(jq .download.bandwidth $FILE)
Downloadresult=$(($Download/125000))
Upload=$(jq .upload.bandwidth $FILE)
Uploadresult=$(($Upload/125000))
PingTime=$(jq .ping.latency $FILE)
ServerHost=$(jq .isp $FILE)
ServerLocation=$(jq .server.location $FILE)
ServerIP=$(jq .server.ip $FILE)
URL=$(jq .result.url $FILE)
Jitter=$(jq .ping.jitter $FILE)

#Send Data to Zabbix
echo "Summarize Data to Zabbix..."
# Summarize Data for Zabbix
echo "-" speedtest.download $Downloadresult >> $ZABBIX_DATA
echo "-" speedtest.upload $Uploadresult >> $ZABBIX_DATA
echo "-" speedtest.wan.ip $ServerIP >> $ZABBIX_DATA
echo "-" speedtest.ping $PingTime >> $ZABBIX_DATA
echo "-" speedtest.srv.name $ServerHost >> $ZABBIX_DATA
echo "-" speedtest.srv.city $ServerLocation >> $ZABBIX_DATA
echo "-" speedtest.URL $URL >> $ZABBIX_DATA
echo "-" speedtest.jitter $Jitter >> $ZABBIX_DATA
echo "Sending Data to Zabbix"
/usr/bin/zabbix_sender --config /etc/zabbix/zabbix_agent2.conf -i $ZABBIX_DATA
rm $ZABBIX_DATA $FILE

