#!/bin/bash

# Define some colors
colorWhite="\e[m"
colorGray="\e[90m"
colorGreen="\e[32m"
colorRed="\e[31m"

# Enter your API details from the cydia connect site here
# myhash is a md5 sum of your VENDOR ID and SECRET KEY
# that you get here https://cydia.saurik.com/connect/api/
myhash=234hgkjhg23j5hvj2h342gh4fh2g3f4hg2f3k4hj2
products="com.username.tweak1
          com.username.tweak2
          com.username.tweak3"
 
# Some starting values
allTweaksTotalSum=0
allTweaksTotalSumToday=0
today=$(date +"%Y-%m-%d")
tempFilePath=$(mktemp /tmp/cydiadata.XXXXXX)

# Draws the table headers
printf "\n\n%30s ${colorGray}|${colorWhite} %8s ${colorGray}|${colorWhite} %5s\n${colorWhite}" "Tweak" "Total" "Today"
printf "${colorGray}--------------------------------------------------${colorWhite}\n"

# Do stuff
for prod in $products;
  do
    # Ask nicely for data
    curl -s "http://cydia.saurik.com/api/roster?package=$prod&vendor-hash=$myhash" > $tempFilePath

    # Calculate total for the whole period
    currentTweakTotalSum=$( cat $tempFilePath | awk '{SUM += $9} END {print SUM}' )
    currentTweakTotalSum=$( echo "$currentTweakTotalSum*0.7" | bc )
    allTweaksTotalSum=$( echo "$allTweaksTotalSum+$currentTweakTotalSum" | bc )

    # Calculate total for today (hopefully there is some sales)
    currentTweakTotalSumToday=$( cat $tempFilePath | grep $today | awk '{SUM += $9} END {print SUM}' )
   
    # Assume no sales today for printing
    # Using this because I'm printing with parantheses
    # And we don't want empty one to be printed 
    todaySalesForPrinting=""

    # Only add currentTweakTotalSumToday if there were anything 
    if [ -n "$currentTweakTotalSumToday" ]; then
        currentTweakTotalSumToday=$( echo "$currentTweakTotalSumToday*0.7" | bc )
        todaySalesForPrinting=$( echo "$currentTweakTotalSumToday" )
        allTweaksTotalSumToday=$( echo "$allTweaksTotalSumToday+$currentTweakTotalSumToday" | bc )
    fi
    
    # Display
    printf "%30s ${colorGray}|${colorWhite} %8s ${colorGray}|${colorWhite} ${colorGreen}%5s\n${colorWhite}" $prod $currentTweakTotalSum $todaySalesForPrinting
  done

# Color
colorForTweakTotalSumToday="${colorGreen}"

# Change to red if there were 0 sales today
#if [ $allTweaksTotalSumToday -eq "" 2> /dev/null ]; then # 0 if no sales, otherwise just dont write the error
#   colorForTotalSum="${colorRed}"
#fi

# And print the last lines, the summary
printf "${colorGray}--------------------------------------------------${colorWhite}\n"
printf "%30s ${colorGray}|${colorWhite} %8s ${colorGray}|${colorWhite} ${colorForTweakTotalSumToday}%5s\n${colorWhite}\n\n" "All" $allTweaksTotalSum $allTweaksTotalSumToday

