SERVERS=`cat servers.txt`
OUTPUT_FILE="certificates.csv"

echo "domain,startDate,endDate" > $OUTPUT_FILE;
for i in $SERVERS; do
	echo -n "$i," >> $OUTPUT_FILE;
	curl --insecure -vI https://$i 2>&1 | tee temp.file
	START_DATE_FMT=`cat temp.file | grep "start date" | sed 's/\*  start date: //g'`;
	END_DATE_FMT=`cat temp.file | grep "expire date" | sed 's/\*  expire date: //g'`;
	START_DATE=`date -d "$START_DATE_FMT" +%Y-%m-%d`;
	END_DATE=`date -d "$END_DATE_FMT" +%Y-%m-%d`
	echo -n "$START_DATE," >> $OUTPUT_FILE;
	echo "$END_DATE" >> $OUTPUT_FILE;
done;

rm temp.file
