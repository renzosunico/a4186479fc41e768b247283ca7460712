#!/bin/bash

    function sendLunch {
        date="$(date +'%d/%m/%Y')";
        menu="$(grep $date ~/Bin/cw-bot/src/foodmenu.csv | cut -d ',' -f3)";
        echo "[info][title]Lunch Advisory[/title]$menu[/info]" > /tmp/lnch.send
        php ~/Bin/cw-bot/send.php "$(cat /tmp/lnch.send)";
        rm /tmp/lnch.send;
    }

    function sendSlackLunch {
        date="$(date +'%d/%m/%Y')";
        menu="$(grep $date ~/Bin/cw-bot/src/foodmenu.csv | cut -d ',' -f3)";
        channels="tc-20142015
tc-batch-2014-2015";

        while read -r channel; do
            echo '"`BREAKING NEWS! LUNCH:`' > /tmp/lnch.send
            echo '```' >> /tmp/lnch.send;
            echo "$menu" >> /tmp/lnch.send;
            echo '```"' >> /tmp/lnch.send;
            payload="$(echo "payload={\"channel\": \"$channel\", \"text\": $(cat /tmp/lnch.send)}")";
            curl -X POST --data-urlencode "$payload" https://hooks.slack.com/services/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;
        done <<< "$channels";

        rm /tmp/lnch.send;

    }

    sendLunch;
