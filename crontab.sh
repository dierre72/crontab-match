#!/bin/bash
################################################
# bash script                                  #
# author Roberto D'Orazio                      #
# Compare crontab string with actual date      #
# returns true if the date matches             #
# based on 'crontab' command                   #
# based on Mikolaj 'Metatron' Niedbala Script  #
# licenced GNU/ GPL                            #
################################################

# Variable Initialization
line=$1
RUN=true
DATE=()
DATE+=($(date +"%M"))
DATE+=($(date +"%H"))
DATE+=($(date +"%d"))
DATE+=($(date +"%m"))
DATE+=($(date +"%u"))

# Check crontab is not empty
if [ -z "$line" ]; then
        echo "Crontab Syntax Error, follow the example"
        echo "String format: m h d mon w"
        echo "Accepted values:"
        echo "1 1,2 1-5 1-4/2 * */2"
        exit 0
fi

# create crontab array
IFS=' '
read -ra CRONTAB <<< $1

# cycle into crontab to check values
for i in "${!CRONTAB[@]}"; do
        CH=${CRONTAB[$i]}
        CH=$(echo "$CH" | sed 's/^0*//')
        CD=${DATE[$i]}
        CD=$(echo "$CD" | sed 's/^0*//')
        if [[ $CH == "*" ]]; then
		continue
	fi
        
	if [[ $CH =~ ^\*\/[0-9]{1,2}$ ]]; then                                  
                NUM=$(echo "$CH" |cut -d"/" -f2);
                if ((CD % NUM)); then
                        RUN=false
		fi
        elif [[ $CH =~ ^[0-9]{1,2}$ ]]; then                                    
                if ! [[ "$CH" = "$CD" ]]; then
                        RUN=false
         	fi
        elif [[ $CH =~ ^[0-9]{1,2}-[0-9]{1,2}$ ]]; then                    
                FR_NUM=$(echo "$CH" |cut -d"-" -f1);
                TO_NUM=$(echo "$CH" |cut -d"-" -f2);
                if ! (( $FR_NUM <= $CD && $CD <= $TO_NUM )); then
                        RUN=false
         	fi
        elif [[ $CH =~ "," ]]; then
                if ! [[ ",$CH," = *",$CD,"* ]]; then
                        RUN=false
                fi
        elif [[ $CH =~ ^[0-9]{1,2}-[0-9]{1,2}\/[0-9]{1,2}$ ]]; then             
                NUM=$(echo "$CH" |cut -d"/" -f2);
                CH_RANGE=$(echo "$CH" |cut -d"/" -f1);
                FR_NUM=$(echo "$CH_RANGE" |cut -d"-" -f1);
                TO_NUM=$(echo "$CH_RANGE" |cut -d"-" -f2);
                if ((CD % NUM)); then
                        RUN=false
                elif ! (( $FR_NUM <= $CD && $CD <= $TO_NUM )); then
                        RUN=false
                fi
	else
		RUN=false
        fi;
done
echo $RUN
exit 0;
