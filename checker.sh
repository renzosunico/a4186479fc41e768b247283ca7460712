#!/bin/bash

    function checkStatus {
        if [ "$?" == "1" ]; then
            echo -e "ENCOUNTERED ERROR!";
            exit 1;
        fi;
    }

    function lineBreak {
        echo -e "**************************************************************************";
    }

    function displayExchange {
        echo -e "[#-#-#-#-#- EXCHANGE -#-#-#-#-#]";
        date_open="$(cat ${path}/loop_quest_master.php | grep -E "'id' => '?${1}" | grep -Eo "'date_start' => '[0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2}" | grep -Eo "[0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2}" )";
        exchange="$(cat ${path}/exchange_master.php | grep -E "'exchange_start' => '$date_open" | grep -Eo "'incentive_id' => [0-9]+" | grep -Eo "[0-9]+")";

        while read -r incentive; do
            displayIncentive "$incentive";
        done <<< "$exchange";
    }

    function displayIncentive {
        incentive_info="$(cat ${path}/incentive_master.php | grep -E "'id' => '?$1\b")";
        incentive_name="$(echo "$incentive_info" | sed "s/\\\'//g" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";

        exist "$incentive_info";

        echo -e "INCENTIVE ID: $1\t : $incentive_name\nCONTENTS:";

        for i in {1..10}; do

            content_category="$(echo "$incentive_info" | grep -Eo "'content${i}_category' => '.+?'" | sed "s/'content${i}_category' => //g;s/'//g")";

            content_id="$(echo "$incentive_info" | grep -Eo "'content${i}_id' => '?[0-9]+" | sed "s/'content${i}_id' => //g;s/'//g")";
            content_amount="$(echo "$incentive_info" | grep -Eo "'content${i}_num' => '?[0-9]+" | sed "s/'content${i}_num' => //g;s/'//g")";

            if [ "$content_category" == "item" ]; then
                displayItem "$content_id" "$content_amount";
                if [ -n "$(echo "$incentive_name" | grep -i "stage")" ]; then
                    echo "$content_id" >> /tmp/item.list;
                fi
            fi

            if [ "$content_category" == "unit_equipment" ]; then
                displayUnitEquipment "$content_id" "$content_amount";
                if [ -n "$(echo "$incentive_name" | grep -i "stage")" ]; then
                    echo "$content_id" >> /tmp/unit_equipment.list
                fi
            fi

            if [ "$content_category" == "guild_item" ]; then
                displayGuildItem "$content_id" "$content_category";
                if [ -n "$(echo "$incentive_name" | grep -i "stage")" ]; then
                    echo "$content_id" >> /tmp/guild_item.list
                fi
            fi

            if [ "$content_category" == "unit" ]; then
                displayUnit "$content_id" "$content_amount";
                if [ -n "$(echo "$incentive_name" | grep -i "stage")" ]; then
                    echo "$content_id" >> /tmp/unit.list;
                fi
            fi

        done;
    }

    function displayItem {
        item_name="$(cat ${path}/item_master.php | sed "s/\\\'//g" | grep -E "'id' => '?$1\b" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";

        exist "$item_name";

        echo -e "\tITEM ID: $1  ";
        echo -e "\tNAME: $item_name";
        if [ -z "$2" ]; then
            echo -e "\tNO: N/A";
        else
            echo -e "\tNO: $2";
        fi
    }

    function displayUnitEquipment {
        equipment="$(cat ${path}/unit_equipment_master.php | sed "s/\\\'//g" | grep -E "'id' => '?$1\b")";

        exist "$equipment";

        equipment_name="$(echo $equipment | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";
        equipment_attack="$(echo $equipment | grep -Eo "'attack' => [0-9]+" | sed "s/'attack' => //g;s/'//g")";
        equipment_defence="$(echo $equipment | grep -Eo "'defence' => [0-9]+" | sed "s/'defence' => //g;s/'//g")";
        equipment_durability="$(echo $equipment | grep -Eo "'durability_description' => '.+?'" | sed "s/'durability_description' => //g;s/'//g")";

        echo -e "\tITEM ID: $content_id  ";
        echo -e "\tNAME: $equipment_name";
        echo -e "\tATTACK: $equipment_attack";
        echo -e "\tDEFENCE: $equipment_defence";
        echo -e "\tDURABILITY: $equipment_durability";
        if [ -z "$2" ]; then
            echo -e "\tNO: N/A";
        else
            echo -e "\tNO: $2";
        fi
    }

    function displayGuildItem {
        guild_item_name="$(cat ${path}/guild_item_master.php | sed "s/\\\'//g" | grep -E "'id' => '?$1\b" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";

        exist "$guild_item_name";

        echo -e "\tITEM ID: $content_id  ";
        echo -e "\tNAME: $guild_item_name";
        if [ -z "$2" ]; then
            echo -e "\tNO: N/A";
        else
            echo -e "\tNO: $2";
        fi
    }

    function displayUnit {
        unit="$(cat ${path}/unit_master.php | grep -E "'id' => $1\b")";
        exist "$unit";
        unit_name="$(echo "$unit" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g";)";
        unit_max_attack="$(echo "$unit" | grep -Eo "'max_attack' => [0-9]+" | grep -Eo "[0-9]+")";
        unit_max_defence="$(echo "$unit" | grep -Eo "'max_defence' => [0-9]+" | grep -Eo "[0-9]+")";
        unit_max_evolution_num="$(echo "$unit" | grep -Eo "'max_evolution_num' => [0-9]+" | grep -Eo "[0-9]+")";
        unit_attack_increase_rate="$(echo "$unit" | grep -Eo "'evolution_attack_increase_rate' => [0-9]+.[0-9]+" | grep -Eo "[0-9]+.[0-9]+")";
        unit_defence_increase_rate="$(echo "$unit" | grep -Eo "'evolution_attack_increase_rate' => [0-9]+.[0-9]+" | grep -Eo "[0-9]+.[0-9]+")";
        unit_race_id="$(echo "$unit" | grep -Eo "'race_id' => [0-9]+" | grep -Eo "[0-9]+")";
        unit_race="$(echo "$unit" | grep -Eo "'race_name' => '.+?'" | sed "s/'race_name' => //g;s/'//g")"
        unit_rarity="$(echo "$unit" | grep -Eo "'rarity' => [0-9]+" | grep -Eo "[0-9]+")";
        unit_description="$(echo "$unit" | sed "s/\\\'//g" | grep -Eo "'description' => '.+?'" | sed "s/'description' => //g;s/'//g")";

        echo -e "\tUNIT ID: $1  ";
        echo -e "\tNAME: $unit_name";
        if [ -z "$2" ]; then
            echo -e "\tNO: N/A";
        else
            echo -e "\tNO: $2";
        fi
        if [ -z "$(cat ${path}/item_unit_use_condition_master.php | grep -E "'exclusive_unit_ids' => [0-9]+")" ] ||
           [ -z "$(cat ${path}/item_unit_use_condition_master.php | grep -E "'rarity_conditon' => ${unit_rarity}" |
                grep -E "'unit_race_condition' => ${unit_race_id}")" ]; then

                php /Users/$(whoami)/Documents/Scripts/macro/calculator.php 'NON_LIMIT' ${unit_max_evolution_num} ${unit_max_attack} ${unit_max_defence} ${unit_attack_increase_rate} ${unit_defence_increase_rate} "NULL" 2> /dev/null;

        else

            php /Users/$(whoami)/Documents/Scripts/macro/calculator.php 'LIMIT_BREAK' ${unit_max_evolution_num} ${unit_max_attack} ${unit_max_defence} ${unit_attack_increase_rate} ${unit_defence_increase_rate} "NULL" 2> /dev/null;
        fi
        echo -e "\tRACE: $unit_race";
        echo -e "\tRARITY: $unit_rarity";
        echo -e "\tNO. OF EVOLUTION: $unit_max_evolution_num";
        echo -e "\tDESCRIPTION: $unit_description";

        if [ "$unit_rarity" == "11" ]; then
            echo "$unit" > /tmp/11Star.Unit
        fi
    }

    function displayMission {
        echo -e "[#-#-#-#-#- MISSIONS -#-#-#-#-#]";
        mission_group="$(cat ${path}/mission_group_master.php | grep -E "'id' => ${2}${1}[0-9]+")";
        while read -r group; do
            group_id="$(echo "$group" | grep -Eo "'id' => [0-9]+" | grep -Eo "[0-9]+")";
            group_title="$(echo "$group" | sed "s/\\\'//g" | grep -Eo "'title' => '.+?'" | sed "s/'title' => //g;s/'//g")";
            echo -e "[[ MISSION GROUP ]]";
            echo -e "ID: $group_id\t TITLE: $group_title";
            echo -e "[[ MISSIONS ]]";

            #Missions
            missions="$(cat ${path}/mission_master.php | grep -E "'mission_group_id' => $group_id")";

            while read -r mission; do
                mission_id="$(echo "$mission" | grep -Eo "'id' => [0-9]+" | grep -Eo "[0-9]+")";
                mission_name="$(echo "$mission" | sed "s/\\\'//g" | grep -Eo "'title' => '.+?'" | sed "s/'title' => //g;s/'//g")";
                incentive_ids="$(echo "$mission" | grep -Eo "'incentive_id' => [0-9]+" | sed "s/'incentive_id' => //g;s/'//g")";
                echo -e "MISSION ID: $mission_id\nTITLE: $mission_name";
                while read -r incentive; do
                    displayIncentive "$incentive";
                done <<< "$incentive_ids";
            done <<< "$missions";
        done <<< "$mission_group";

    }

    function displayStageRewards {
        echo -e "[#-#-#-#-#- STAGE -#-#-#-#-#]";
        incentive_ids="$(cat ${path}/loop_quest_mission_reward_master.php |
                        grep -E "'loop_quest_section_id' => $1" | grep -Eo "'incentive_id' => [0-9]+" |
                        grep -Eo "[0-9]+" | sed "s/'incentive_id' => //g;s/'//g")";
        while read -r incentive; do
            displayIncentive "$incentive";
        done <<< "$incentive_ids";
    }

    function displayStartDash {
        echo -e "[#-#-#-#-#- START DASH -#-#-#-#-#]";
        incentive_ids="$(cat ${path}/system_value_modifier_master.php | grep -E "'master' => 'LoopQuestMissionRewardMaster'" |
                        grep -Eo "'value' => '?10${1}[0-9]+" | grep -Eo "[0-9]+")";
        while read -r incentive_id; do
            displayIncentive "$incentive_id";
        done <<< "$incentive_ids";
    }

    function displayIndividualRewards {
        echo -e "[#-#-#-#-#- INDIVIDUAL REWARDS -#-#-#-#-#]";
        incentive_ids="$(cat ${path}/loop_quest_player_rank_reward_master.php |
                        grep -E "'loop_quest_section_id' => $1" | grep -Eo "'incentive_id' => '?[0-9]+" |
                        grep -Eo "[0-9]+")";
        while read -r incentive; do
            displayIncentive "$incentive";
        done <<< "$incentive_ids";
    }

    function displayBonusSchedule {
        echo -e "[#-#-#-#-#- BONUS SCHEDULE -#-#-#-#-#]";

        schedule="$(cat ${path}/quest_bonus_up_schedule_master.php | grep -E "'loop_quest_section_id' => $1\b")";

        while read -r sched; do
            lineBreak;
            echo -e "START:\t$(echo "$sched" | grep -Eo "'date_open' => '.+?'" | sed "s/'date_open' => //g;s/'//g")";
            echo -e "END:\t$(echo "$sched" | grep -Eo "'date_close' => '.+?'" | sed "s/'date_close' => //g;s/'//g")";
            echo -e "BONUS RATE:\t$(echo "$sched" | grep -Eo "'bonus_rate' => [0-9.]+" | grep -Eo "[0-9.]+")";
        done <<< "$schedule";
    }

    function displayTitle {
        echo -e "[#-#-#-#-#- NEW TITLE -#-#-#-#-#]";

        title_info="$(cat ${path}/title_master.php | grep -E "'incentive_id' => [0-9]+$1[0-9]+\b")";

        exist "$title_info";

        while read -r title; do
            name="$(echo "$title" | sed "s/\\\'//g" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";
            incentive_id="$(echo "$title" | grep -Eo "'incentive_id' => [0-9]+" | grep -Eo "[0-9]+")";
            until="$(echo "$title" | grep -Eo "'date_end' => '.+?'" |  sed "s/'date_end' => //g;s/'//g")";
            min_equip="$(echo "$title" | grep -Eo "'min_equip_hour' => [0-9]+" |  grep -Eo "[0-9]+")";

            element_id="$(echo "$title" | grep -Eo "'element_id' => [0-9]+" | grep -Eo "[0-9]+")";
            element_info="$(cat ${path}/title_element_master.php | grep -E "'id' => $element_id\b")";
            element_name="$(echo "$element_info" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g" )";

            rank_id="$(echo "$title" | grep -Eo "'rank_id' => [0-9]+" | grep -Eo "[0-9]+")";
            rank_info="$(cat ${path}/title_rank_master.php | grep -E "'id' => $rank_id\b")";
            rank_name="$(echo "$rank_info" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g" )";
            rank_attack_multiplier="$(echo "$rank_info" | grep -Eo "'attack_multiplier' => [0-9]+" |  grep -Eo "[0-9]+")";
            rank_damage_multiplier="$(echo "$rank_info" | grep -Eo "'damage_multiplier' => [0-9]+" |  grep -Eo "[0-9]+")";

            effect_type="$(echo "$title" | grep -Eo "'effect_type' => [0-9]+" | grep -Eo "[0-9]+")";


            lineBreak;
            echo -e "\tNAME: $name";
            echo -e "\tELEMENT ID: $element_id";
            echo -e "\tELEMENT NAME: $element_name";


            for i in {1..10}; do

                target_element_id="$(echo "$element_info" | grep -Eo "'target_element_id${i}' => [0-9]+" | sed "s/'target_element_id${i}' => //g;s/'//g")";
                target_element_name="$(cat ${path}/title_element_master.php | grep -E "'id' => $target_element_id\b" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g" )";
                attack_multiplier="$(echo "$element_info" | grep -Eo "'attack_multiplier${i}' => [0-9]+" | sed "s/'attack_multiplier${i}' => //g;s/'//g")";
                damage_multiplier="$(echo "$element_info" | grep -Eo "'damage_multiplier${i}' => [0-9]+" | sed "s/'damage_multiplier${i}' => //g;s/'//g")";

                if [ -z "$target_element_id" ]; then
                    break;
                fi

                echo -e "\tTARGET ELEMENT #${i}";
                echo -e "\tID: $target_element_id";
                echo -e "\tELEMENT: $target_element_name";
                echo -e "\tATTACK MULTIPLIER: $attack_multiplier %";
                echo -e "\tDEFENCE MULTIPLIER: $damage_multiplier %";

             done;

            echo -e "\tRANK ID: $rank_id";
            echo -e "\tRANK: $rank_name";
            echo -e "\tATTACK MULTIPLIER: $rank_attack_multiplier";
            echo -e "\tDAMAGE MULTIPLIER: $rank_damage_multiplier";

            displayIncentive "$incentive_id";
            echo -e "\tUNTIL REMOVABLE: $min_equip HOUR";
            echo -e "\tOBTAINABLE UNTIL: $until";



        done <<< "$title_info";
    }

    function displayDropItemPeriod {
        echo -e "[#-#-#-#-#- DROP ITEM CAMPAIGN -#-#-#-#-#]";
        drop_item_id="$(cat ${path}/loop_quest_drop_item_master.php | grep -E "'loop_quest_section_id' => '?$1" | grep -Eo "'id' => '?[0-9]+" | grep -Eo "[0-9]+" | head -n1)";
        drop_item_schedule="$(cat ${path}/system_value_modifier_master.php | grep -E "LoopQuestDropItemMaster" | grep -E "'target_id' => '?${drop_item_id}")";

        while read -r schedule; do
            date_start="$(echo "$schedule" | grep -Eo "'date_start' => '.+?'" | sed "s/'date_start' => //g;s/'//g")";
            date_end="$(echo "$schedule" | grep -Eo "'date_end' => '.+?'" | sed "s/'date_end' => //g;s/'//g")";
            column="$(echo "$schedule" | grep -Eo "'column' => '.+?'" | sed "s/'column' => //g;s/'//g")";
            range="$(echo "$schedule" | grep -Eo "'target_id' => '.+?'" | sed "s/'target_id' => //g;s/'//g")";
            new_value="$(echo "$schedule" | grep -Eo "'value' => '?[0-9]+" | sed "s/'value' => //g;s/'//g")";

            echo -e "\tDATE START: $date_start";
            echo -e "\tDATE END: $date_end";
            echo -e "\tCOLUMN TO CHANGE: $column";
            echo -e "\tID TO CHANGE: $range";
            echo -e "\tNEW ID: $new_value";
            echo -e "\tDESCRIPTION: ";
                displayItem "$new_value";

        done <<< "$drop_item_schedule";
    }

    function displayElevenStar {
        echo -e "[#-#-#-#-#- 11 STARS -#-#-#-#-#]";
        if [ -f "/tmp/11Star.Unit" ]; then
            unit="$(cat /tmp/11Star.Unit)";
            unit_id="$(echo "$unit" | grep -Eo "'id' => [0-9]+" | grep -Eo "[0-9]+")";
            unit_name="$(echo "$unit" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g";)";
            unit_max_attack="$(echo "$unit" | grep -Eo "'max_attack' => [0-9]+" | grep -Eo "[0-9]+")";
            unit_max_defence="$(echo "$unit" | grep -Eo "'max_defence' => [0-9]+" | grep -Eo "[0-9]+")";
            unit_max_evolution_num="$(echo "$unit" | grep -Eo "'max_evolution_num' => [0-9]+" | grep -Eo "[0-9]+")";
            unit_attack_increase_rate="$(echo "$unit" | grep -Eo "'evolution_attack_increase_rate' => [0-9]+.[0-9]+" | grep -Eo "[0-9]+.[0-9]+")";
            unit_defence_increase_rate="$(echo "$unit" | grep -Eo "'evolution_attack_increase_rate' => [0-9]+.[0-9]+" | grep -Eo "[0-9]+.[0-9]+")";
            unit_race_id="$(echo "$unit" | grep -Eo "'race_id' => [0-9]+" | grep -Eo "[0-9]+")";
            unit_rarity="$(echo "$unit" | grep -Eo "'rarity' => [0-9]+" | grep -Eo "[0-9]+")";
            unit_description="$(echo "$unit" | sed "s/\\\'//g" | grep -Eo "'description' => '.+?'" | sed "s/'description' => //g;s/'//g")";

            echo -e "\tUNIT ID: $unit_id";
            echo -e "\tNAME: $unit_name";
            if [ -z "$(cat ${path}/item_unit_use_condition_master.php | grep -E "'exclusive_unit_ids' => [0-9]+")" ] ||
               [ -z "$(cat ${path}/item_unit_use_condition_master.php | grep -E "'rarity_conditon' => ${unit_rarity}" |
                    grep -E "'unit_race_condition' => ${unit_race_id}")" ]; then

                    php /Users/$(whoami)/Documents/Scripts/macro/calculator.php 'NON_LIMIT' ${unit_max_evolution_num} ${unit_max_attack} ${unit_max_defence} ${unit_attack_increase_rate} ${unit_defence_increase_rate} "BREAKDOWN";

            else

                php /Users/$(whoami)/Documents/Scripts/macro/calculator.php 'LIMIT_BREAK' ${unit_max_evolution_num} ${unit_max_attack} ${unit_max_defence} ${unit_attack_increase_rate} ${unit_defence_increase_rate} "BREAKDOWN";
            fi
            echo -e "\tRARITY: $unit_rarity";
            echo -e "\tNO. OF EVOLUTION: $unit_max_evolution_num";
            echo -e "\tDESCRIPTION: $unit_description";
        else
            echo -e "\tNO 11 Star Unit Found!";
        fi

    }

    function displayCoinSale {
        echo -e "[#-#-#-#-#- COIN SALE -#-#-#-#-#]";
        read -p "Please enter product name: " product;
        exist "$product";

        item_id="$(cat ${path}/item_master.php | grep -E "'name' => '$product" | grep -Eo "'id' => '?[0-9]+" | grep -Eo "[0-9]+")";
        product_id="$(cat ${path}/product_master.php | grep -E "'content1_id' => '?$item_id" | grep -Eo "'id' => '?[0-9]+" | grep -Eo "[0-9]+")";

        while read -r id; do
            displayProduct "$id";
            lineBreak;
        done <<< "$product_id";

    }

    function displayProduct {
        product="$(cat ${path}/product_master.php | grep -E "'id' => '?$1")";
        name="$(echo "$product" | grep -Eo "'name' => '?.+?'" | sed "s/'name' => //g;s/'//g")";
        date_start="$(echo "$product" | grep -Eo "'date_start' => '?.+?'" | sed "s/'date_start' => //g;s/'//g")";
        date_end="$(echo "$product" | grep -Eo "'date_end' => '?.+?'" | sed "s/'date_end' => //g;s/'//g")";
        price="$(echo "$product" | grep -Eo "'price' => '?[0-9]+" | grep -Eo "[0-9]+")";
        mode="$(echo "$product" | grep -Eo "'payment_method' => '?.+?'" | sed "s/'payment_method' => //g;s/'//g")";
        limited_num="$(echo "$product" | grep -Eo "'limited_num' => '?[0-9]" | grep -Eo "[0-9]+")";

        echo -e "\tPRODUCT ID: $1";
        echo -e "\tNAME: $name";
        echo -e "\tPRICE: $price";
        echo -e "\tMODE OF PAYMENT: $mode";
        echo -e "\tBUY LIMIT: $limited_num";
        echo -e "\tDATE START: $date_start";
        echo -e "\tDATE END: $date_end";
        echo -e "\tCONTENTS: ";

        for i in {1..10}; do

            content_category="$(echo "$product" | grep -Eo "'content${i}_category' => '.+?'" | sed "s/'content${i}_category' => //g;s/'//g")";

            content_id="$(echo "$product" | grep -Eo "'content${i}_id' => '?[0-9]+" | sed "s/'content${i}_id' => //g;s/'//g")";
            content_amount="$(echo "$product" | grep -Eo "'content${i}_num' => '?[0-9]+" | sed "s/'content${i}_num' => //g;s/'//g")";

            if [ "$content_category" == "item" ]; then
                displayItem "$content_id" "$content_amount";
            fi

            if [ "$content_category" == "unit_equipment" ]; then
                equipment="$(cat ${path}/unit_equipment_master.php | sed "s/\\\'//g" | grep -E "'id' => '?$content_id\b")";
                equipment_name="$(echo $equipment | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";
                equipment_attack="$(echo $equipment | grep -Eo "'attack' => [0-9]+" | sed "s/'attack' => //g;s/'//g")";
                equipment_defence="$(echo $equipment | grep -Eo "'defence' => [0-9]+" | sed "s/'defence' => //g;s/'//g")";
                equipment_durability="$(echo $equipment | grep -Eo "'durability_description' => '.+?'" | sed "s/'durability_description' => //g;s/'//g")";

                echo -e "\tITEM ID: $content_id  ";
                echo -e "\tNAME: $equipment_name";
                echo -e "\tATTACK: $equipment_attack";
                echo -e "\tDEFENCE: $equipment_defence";
                echo -e "\tDURABILITY: $equipment_durability";
                echo -e "\tNO: $content_amount";
            fi

            if [ "$content_category" == "guild_item" ]; then
                item_name="$(cat ${path}/guild_item_master.php | sed "s/\\\'//g" | grep -E "'id' => '?$content_id\b" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";
                echo -e "\tITEM ID: $content_id  ";
                echo -e "\tNAME: $item_name";
                echo -e "\tNO: $content_amount";
            fi

            if [ "$content_category" == "unit" ]; then
                displayUnit "$content_id" "$content_amount";
            fi

        done;


    }

    function exist {
        if [ -z "$1" ]; then
            echo -e "Cannot find keyword. Please download updated master from stg.";
            exit 1;
        fi
    }

    function pauseWait {
        echo -e "\n\n\n";
        read -p "Press any key to continue..." continue;
        clear;
    }

    function displaySummaryStageRewards {

        echo -e "[#-#-#-#-#- STAGE REWARDS SUMMARY -#-#-#-#-#]";

        echo -e "{ * * * * UNITS * * * * }";
        if [ -f "/tmp/unit.list" ]; then
            id="$(cat /tmp/unit.list | sort | uniq)";

            while read -r warrior; do
                displayUnit "$warrior";
            done <<< "$id";

        fi;

        pauseWait;

        echo -e "{ * * * * UNIT EQUIPMENT * * * * }";
        if [ -f "/tmp/unit_equipment.list" ]; then
            id="$(cat /tmp/unit_equipment.list | sort | uniq)";

            while read -r equipment; do
                displayUnitEquipment "$equipment";
            done <<< "$id";
        fi

        pauseWait;

        echo -e "{ * * * * GUILD ITEMS * * * * }";
        if [ -f "/tmp/guild_item.list" ]; then
            id="$(cat /tmp/guild_item.list | sort | uniq)";

            while read -r item; do
                displayGuildItem "$item";
            done <<< "$id";
        fi

        pauseWait;

        echo -e "{ * * * * ITEMS * * * * }";
        if [ -f "/tmp/item.list" ]; then
            id="$(cat /tmp/item.list | sort | uniq)";

            while read -r item; do
                displayItem "$item";
            done <<< "$id";
        fi

    }

    function displayGuildAchievementRewards {
        echo -e "[#-#-#-#-#- GUILD ACHIEVEMENT REWARDS -#-#-#-#-#]";
        incentive_ids=`cat ${path}/loop_quest_guild_achievement_reward_master.php | grep -E "'loop_quest_id' => '?$1\b" | grep -Eo "'incentive_id' => [0-9]+" | grep -Eo "[0-9]+"`;
        while read -r id; do
            displayIncentive "$id";
        done <<< "$incentive_ids";
    }

    function displayGuildRankingReward {
        echo -e "[#-#-#-#-#- GUILD RANK REWARDS -#-#-#-#-#]";
        incentive_ids=`cat ${path}/loop_quest_guild_rank_reward_master.php | grep -E "'loop_quest_id' => '?$1\b" | grep -Eo "'incentive_id' => [0-9]+" | grep -Eo "[0-9]+"`;
        while read -r id; do
            displayIncentive "$id";
        done <<< "$incentive_ids";
    }

    path="";

    while ! [ -d "$path" ]; do
        read -p "Enter path of masters: " path;
            if [ -d "$path" ]; then
                ls "$path";
                read -p "Is this directory correct? (Y,N): " reply;
                if [ "$reply" == "Y" ] || [ "$reply" == "y" ]; then
                    break;
                else
                    path="";
                    clear;
                fi;
            else
                echo -e "$path is not a directory.";
            fi;
    done;

    path="$(echo "${path}" | sed 's|/$||g')";
displayElevenStar "$loop_quest_id";

    # MODE
    clear;
    echo -e "CHOOSE ACTION: ";
    PS3="CHOICE: ";
    select choice in "LOOP QUEST" "GUILD WAR" "DOWNLOAD MASTER FILES" "DOWNLOAD ALL MASTER FILES EXIT"; do
        case $REPLY in
            1 )
                clear;
                echo -e "${choice} EVENT SELECTED.";
                read -p "Enter loop quest ID: " loop_quest_id;
                clear;

                #[ABOUT TAB]
                echo -e "[*~*~*~*~*~*~ ABOUT TAB ~*~*~*~*~*~*~*]";

                echo -e "[#-#-#-#-#- UNIT WITH SKILL -#-#-#-#-#]";
                skill="$(cat ${path}/loop_quest*skill*.php | grep -E "'loop_quest_id' => ${loop_quest_id}")";

                while read -r line; do

                    lineBreak;

                    unit_id="$(echo "$line" | grep -Eo "'unit_id' => [0-9]+" | grep -Eo "[0-9]+")";
                    displayUnit "$unit_id";
                    skill_effect_type="$(echo "$line" | grep -Eo "'effect_type' => '.+?'" | sed "s/'effect_type' => //g;s/'//g" )";
                    skill_effect_target="$(echo "$line" | grep -Eo "'effect_target_ids' => '.+?'" | sed "s/'effect_target_ids' => //g;s/'//g" | tr ',' '\n' )";
                    skill_target_category="$(echo "$line" | grep -Eo "'effect_target_category' => '.+?'" | sed "s/'effect_target_category' => //g;s/'//g" )";
                    skill_effect_rate="$(echo "$line" | grep -Eo "'effect_coefficient' => [0-9.]+" | grep -Eo "[0-9.]+")";


                    echo -e "\tEFFECT TYPE: $skill_effect_type";
                    if ! [ -z "$skill_target_category" ]; then
                        echo -e "\tITEM SKILLS:";
                        while read -r item; do
                            echo -e "\tID: $item \t NAME: $(cat ${path}/${skill_target_category}*master*.php | grep -E "'id' => ${item}" | grep -Eo "'name' => '.+?'" | sed "s/'name' => //g;s/'//g")";
                        done <<< "$skill_effect_target";
                    fi
                    if ! [ -z "$skill_effect_rate" ]; then
                        echo -e "\tEFFECT RATE: $skill_effect_rate";
                    fi;

                done <<< "$skill";

                pauseWait;

                displayExchange "$loop_quest_id";

                pauseWait;

                displayStageRewards "$loop_quest_id";

                displayStartDash "$loop_quest_id";

                pauseWait;

                displayIndividualRewards "$loop_quest_id";

                pauseWait;

                displayMission "$loop_quest_id" "10";

                pauseWait;

                displayBonusSchedule "$loop_quest_id";

                pauseWait;

                #[CAMPAIGN TAB]
                echo -e "[*~*~*~*~*~*~ CAMPAIGN TAB ~*~*~*~*~*~*~*]";

                displayTitle "$loop_quest_id";

                pauseWait;

                displayDropItemPeriod "$loop_quest_id";

                pauseWait;

                displayMission "$loop_quest_id" "10";

                pauseWait;

                displayElevenStar "$loop_quest_id";

                pauseWait;

                displayCoinSale "$loop_quest_id";

                pauseWait;

                #[STAGE REWARDS]
                echo -e "[*~*~*~*~*~*~ STAGE REWARDS ~*~*~*~*~*~*~*]";

                pauseWait;

                displaySummaryStageRewards;

                pauseWait;

                displayStartDash;

                pauseWait;

                displayGuildAchievementRewards "$loop_quest_id";

                pauseWait;

                #[RANK REWARDS]
                echo -e "[*~*~*~*~*~*~ RANKING REWARDS ~*~*~*~*~*~*~*]";

                displayIndividualRewards "$loop_quest_id";

                pauseWait;

                displayGuildRankingReward "$loop_quest_id";

                pauseWait;

                #[RANK REWARDS]
                echo -e "[*~*~*~*~*~*~ EXCHANGE REWARDS ~*~*~*~*~*~*~*]";

                displayExchange;

                pauseWait;

                ;;
            2 )
                echo -e "${choice} EVENT SELECTED.";
                break;
                ;;

            3 )
                masters="loop_quest
raid
incentive
exchange
title
quest_bonus_up_schedule
system_value_modifier
unit
item
guild_item
mission
guild_mission
product";
                while read -r master; do
                    scp project@master.en.lods.klabgames.net:/opt/klab/contents/project/app/master/${master}*.php ${path}/.
                done <<< "$masters";
                break;
                ;;

            4 )
                read -p "THIS MAY TAKE A WHILE. CONTINUE? (Y, N): " reply
                if [ "$reply" == "y" ] || [ "$reply" == "Y" ]; then
                  scp project@master.en.lods.klabgames.net:/opt/klab/contents/project/app/master/*.php ${path}/.
                  break;
                fi
                ;;
            5 )
                exit 0;
                ;;
            * )
                echo -e "${REPLY} IS INVALID.";
                ;;
        esac
    done;
