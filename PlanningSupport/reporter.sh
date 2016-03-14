#!/bin/sh
export LC_ALL=en_US.UTF-8
source Common.sh;
clear;
cat release-notes;
fetch_logs;

#Option Selection
echo "What do you want to do?";
PS3="I would like to: ";
select choice in "Report Automatically" "Report Manually" "Add Filter" "Exit"; do
    case $REPLY in
        1 )
            while [ -z `echo $timeout | grep -E "^[0-9]+$"` ]; do
                read -p "Timeout (seconds): " timeout;
            done;
            get_current_count;
            while [ true ]; do
                sleep $timeout;
                check_logs;
                sleep $timeout;
            done&
            clear;
            cat auto;
            echo -e "\n\nWhat do you want to do?";
            select option in "Add Filter" "Exit"; do
                display_auto_prompt;
                case $REPLY in
                    1 )
                        add_filter;
                        ;;
                   2 )
                        terminate;
                        ;;
                    * )
                        echo "Invalid choice.";
                        ;;
                esac;
            done;
            ;;
        2 )
            clear;
            cat manual;
            echo -e "\n\nWhat do you want to do?";
            select option in "Check and Send Now" "Add Filter" "Exit"; do
                display_manual_prompt;
                case $REPLY in
                    1 )
                        check_logs;
                        ;;
                    2 )
                        add_filter;
                        ;;
                    3 )
                        terminate;
                        ;;
                    * )
                        echo "Invalid choice.";
                        ;;
                esac;
            done;
            ;;
        3 )
            add_filter;
            ;;
        4 )
            terminate;
            ;;
        * )
            echo "Invalid choice.";
    esac;
done;



