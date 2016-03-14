#!/bin/bash

    function sendCoffeeBreak {
        echo "[info][title]Coffee Break[/title]It'ssssssssssss breaktimeeeeeeee! (cracker)(cracker)" > /tmp/cffbrk.send;
        php ~/Bin/cw-bot/send.php "$(cat /tmp/cffbrk.send)";
        rm /tmp/cffbrk.send;
    }

    sendCoffeeBreak;