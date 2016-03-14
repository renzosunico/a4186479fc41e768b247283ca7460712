#!/usr/bin/env bash

    function displayError {
        if [ "$error" != "peak memory" ]; then
            echo -n "$error: ";
            cat /opt/klab/home/project/renzo-cysco/temp.log | wc -l;
            cat /opt/klab/home/project/renzo-cysco/temp.log;
        else
            echo -n "Peak Memory Usage: ";
            cat /opt/klab/home/project/renzo-cysco/temp.log | wc -l;
            echo -n "Highest: ";
            cat /opt/klab/home/project/renzo-cysco/temp.log | cut -f3 | jq '.message' | grep -o "[0-9]*" | sort | tail -1;
            cat /opt/klab/home/project/renzo-cysco/temp.log;
        fi;
    }

    echo -e "CHOOSE ENVIRONMENT: ";
    PS3="ENVIRONMENT: ";
    select choice in "EN" "JP"; do
        case $REPLY in
            1 )
                using_env="$REPLY";
                time_start="03:00:00";
                break;
                ;;
            2 )
                using_env="$REPLY";
                time_start="17:00:00";
                break;
                ;;
            * )
                echo -e "INVALID ANSWER!";
                ;;
        esac
    done;

errors="Lock wait timeout exceeded
deadlock
peak memory
MasterRecordNotFoundException";

    while read -r error; do
        yesterday=`date -d "1 days ago" '+%Y-%m-%d'`;
        today=`date '+%Y-%m-%d'`;

        zcat /opt/klab/fs/fluent/app.log/app.log.0${using_env}.${yesterday}-*.gz | grep  -Ei "$error" | awk \
          '$0 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]/
              {
                if ($1" "$2 >= "'"$yesterday"'T'"$time_start"'")  p=1;
                if ($1" "$2 >= "'"$yesterday"'T23:59:59")  p=0;
              }
            p { print $0 }' > /opt/klab/home/project/renzo-cysco/temp.log;
        zcat /opt/klab/fs/fluent/app.log/app.log.0${using_env}.${today}-*.gz | grep  -Ei "$error" | awk \
          '$0 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]/
              {
                if ($1" "$2 >= "'"$yesterday"'T'"$time_start"'")  p=1;
                if ($1" "$2 >= "'"$today"'T23:59:59")  p=0;
              }
            p { print $0 }' >> /opt/klab/home/project/renzo-cysco/temp.log;

        echo -e "\n * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *";

        displayError;

    done <<< "$errors";

    echo -e "\n * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n";

    if [ "`date '+%A'`" == "Monday" ]; then
        echo -e "REPORT OVER THE WEEKEND";
        for i in "2" "1"; do
            specific=`date -d "${i} days ago" '+%Y-%m-%d'`;
            echo -e "DATE: $specific";
            while read -r error; do
                zcat /opt/klab/fs/fluent/app.log/app.log.0${using_env}.${specific}-*.gz | grep  -i "$error"  > /opt/klab/home/project/renzo-cysco/temp.log;
                displayError;
                echo -e "\n * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *";
            done <<< "$errors";
        done;

    fi
