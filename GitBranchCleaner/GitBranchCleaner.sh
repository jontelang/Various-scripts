#!/bin/bash

#
function yes_prompt
{
	# echo;
	echo -en "${gray}\"yes\" to continue: ${clear}";
	read key

	if [[ $key != "yes" ]]; then 
		 # echo -en "\r\033[K";
		# echo;
	# else
	    echo "Exiting";
	    exit 1;
	fi
}

#
function delete_prompt ()
{
	# echo;
	echo -en "${gray}\"delete\" to do it (anything else to continue/skip): ${clear}";
	read key

	if [[ $key != "delete" ]]; then 
	    echo -e "${green}---->Skipping delete of [$1]${clear}";
	else
		echo -e "${red}---->DELETING [$1]${clear}";
		git branch -d $1;
	fi
}

#
function continue_prompt
{
	echo;
	echo -en "${gray}Press [Enter] to continue...${clear}";
	read -s -n 1 key

	if [[ $key = "" ]]; then 
		echo -en "\r\033[K";
	else
	    echo "You didn't press [Enter], exiting";
	    exit 1;
	fi
}

#
green='\033[1;32m';
blue='\033[1;33m';
red='\033[1;34m';
red='\033[1;34m';
gray='\033[1;30m';
clear='\033[0m';

#
IOS_APP_FOLDER=REPO_DIR/; # last "/" is important
cd $IOS_APP_FOLDER
echo -e "CDing to ${blue}$IOS_APP_FOLDER${clear}";
echo -e "pwd is: ${blue}$(pwd)${clear}"

CURRENT_BRANCH=$(git branch | grep "\*" | sed s/\*\ //);

echo;
echo -n "Have you done a FETCH? "; yes_prompt;
echo -n "DOWNLOADED the LATEST FEATURE BRANCH? "; yes_prompt;
echo -n "Are ALL branches UP TO DATE? "; yes_prompt;
echo -n "Pushed, pulled, nothing staged and so on? "; yes_prompt;
echo -n "... sure? "; yes_prompt;

echo;
echo -e "current branch is ${red}$CURRENT_BRANCH${clear}";
echo -ne "Is this the latest most up to date branch that you will work on?\nThe local branches which are merged INTOthis one will be\n(prompted) to be deleted. So if it is NOT, then quit and checkout\nthe branch you want. ";
yes_prompt;

echo;
echo -e "This is a list (git branch --list) of all branches in ${blue}$IOS_APP_FOLDER${clear}";  
# continue_prompt;
echo "-------------------------------"
git branch --list; 
echo "-------------------------------"
continue_prompt;

cd $IOS_APP_FOLDER;
ALL_BRANCHES=$(git branch | sed s/\*// | awk '{print $1}');
arr=$(echo $ALL_BRANCHES | tr " " "\n")

echo -e "This is a list of all the merged-or-not statues for each branch in relation to the current branch which is ${blue}$CURRENT_BRANCH${clear}.";  
# continue_prompt;
echo "-------------------------------"

for x in $arr
do 
	IN_MERGED=$(git branch --merged | sed s/\*// | awk '{print $1}' | grep $x)
	IS_WHITELIST=$(echo $x | grep "\*\|master\|QA_TESTING\|iOS_*_*\|Apple_*\|Development\|QA")
	
	if [ "$IS_WHITELIST" != "" ]; then
		echo -e "${gray}$x - Whitelisted${clear}";
	elif [ "$x" == "$IN_MERGED" ]; then
        echo -e "$x - ${green}Merged, CAN be deleted${clear}";
	else
		echo -e "$x - ${blue}NOT merged, keeping it${clear}";
	fi

done

echo "-------------------------------"

echo;
echo "We will now go through each one of the deletable and prompt for deletion. Start process? ";
yes_prompt;

for x in $arr
do 
	IN_MERGED=$(git branch --merged | sed s/\*// | awk '{print $1}' | grep $x)
	IS_WHITELIST=$(echo $x | grep "\*\|master\|QA_TESTING\|iOS_*_*\|Apple_*\|Development\|QA")
	
	if [ "$IS_WHITELIST" != "" ]; then
		echo -e "${gray}$x - Whitelisted${clear}";
	elif [ "$x" == "$IN_MERGED" ]; then
        echo -en "$x - ${green}Merged, CAN be deleted${clear}. Delete? "; delete_prompt $x;
	else
		echo -e "$x - ${blue}NOT merged, keeping it${clear}";
	fi

done
