#!/bin/bash

    function sendBreakfast {
        date="$(date +'%d/%m/%Y')";
        menu="$(grep $date ~/Bin/cw-bot/src/foodmenu.csv | cut -d ',' -f2)";
        echo "[info][title]Breakfast[/title]$menu[/info]" > /tmp/bf.send
        php ~/Bin/cw-bot/send.php "$(cat /tmp/bf.send)";
        rm /tmp/bf.send;
    }

    function sendSlackBreakfast {
        date="$(date +'%d/%m/%Y')";
        menu="$(grep $date ~/Bin/cw-bot/src/foodmenu.csv | cut -d ',' -f2)";
        channels="tc-20142015
tc-batch-2014-2015";

        while read -r channel; do
            echo '"`BREAKING NEWS! BREAKFAST:`' > /tmp/bf.send
            echo '```' >> /tmp/bf.send;
            echo "$menu" >> /tmp/bf.send;
            echo '```"' >> /tmp/bf.send;
            payload="$(echo "payload={\"channel\": \"$channel\", \"text\": $(cat /tmp/bf.send)}")";
            curl -X POST --data-urlencode "$payload" https://hooks.slack.com/services/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;
        done <<< "$channels";

        rm /tmp/bf.send;
    }

    sendBreakfast;