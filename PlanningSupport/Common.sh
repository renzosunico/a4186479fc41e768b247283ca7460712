function fetch_logs() {
    echo "Fetching logs from server.. Please wait..";
    sleep 30
    touch error.jp;
    touch php.jp;

}

function get_current_count() {
    error_en=`cat error.en | wc -l`;
    php_en=`cat php.en | wc -l`;
    error_jp=`cat error.jp | wc -l`;
    php_jp=`cat php.jp | wc -l`;
}

function check_logs() {
    for f in "error.en" "php.en" "error.jp" "php.jp"; do
        get_last_line $f;
        if ! [ $last_line -eq 0 ]; then
            cat "$f" | tail -n ${last_line} > message;
            apply_filter;
            if [ `cat message | wc -l` -gt 0 ]; then
                build_message;
                #send_message;
            cat /tmp/message;
            fi
        fi;

    done;
}

function get_last_line() {
    
    last_line=0;

    if [ "$1" == "error.en" ]; then
        old_count=$error_en;
        new_count=`cat error.en | wc -l`;
        error_en=$new_count;
        category='`ERROR LOG` `EN`';

    elif [ "$1" == "php.en" ]; then
        old_count=$php_en;
        new_count=`cat php.en | wc -l`;
        php_en=$new_count;
        category='`PHP LOG` `EN`';

    elif [ "$1" == "error.jp" ]; then
        old_count=$error_jp;
        new_count=`cat error.jp | wc -l`;
        error_jp=$new_count;
        category='`ERROR LOG` `JP`';

    elif [ "$1" == "php.jp" ]; then
        old_count=$php_jp;
        new_count=`cat php.jp | wc -l`;
        php_jp=$new_count;
        category='`PHP LOG` `JP`';

    fi;

    if ! [ $old_count -eq 0 ]; then
        last_line="$(($old_count - $new_count))";
    else
        last_line=$new_count;
    fi
}

function apply_filter() {
    cat message | grep -E "\[w[0-9]+\] out: \[" | tee new;
    cat new > message;

    while read filter; do
        cat message | grep -Evi "$filter" > new;
        cat new > message;
    done < filters
}

function display_manual_prompt() {
    clear;
    cat manual;
    echo -e "\n\nWhat do you want to do?";
    echo "1) Check and Send Now";
    echo "2) Exit";
}

function display_auto_prompt() {
    clear;
    cat auto;
    echo "\n\nWhat do you want to do?";
    echo "1) Add Filter";
    echo "2) Exit";
}

function build_message() {
    echo "$category" > /tmp/message;
    c_block='```';
    message=`cat message`;
    echo "$c_block $message $c_block" >> /tmp/message;
}

function send_message() {
    channel="#lods-ope_inv";
    payload="$(echo "payload={\"channel\": \"$channel\", \"text\": \"$(cat /tmp/message)\"}")";
    curl -X POST --data-urlencode "$payload" https://hooks.slack.com/services/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;
}

function add_filter() {
    read -p "Enter keyword: " keyword;
    echo -E "\n$keyword\n" >> filters;
    echo "$keyword has been added.";
}

function terminate() {
    jobs=`jobs -pr`;
    echo "Terminating script.."
    while read -r job; do
        echo "Killing process $job..";
        kill -9 $job;
    done <<< "$jobs";
    echo "Deleting temporary files";
    rm *.en *.jp;
    > message;
    echo "Script halted.";
    exit 0;
}