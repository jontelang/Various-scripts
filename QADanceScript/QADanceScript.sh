#!/bin/bash

# Is the first parameter/argument sent to the script
autoOverwrite=$1 # Can be "-f" or nothing at all

# Set these up with your own branches and dirs
REPO_DIR=DIR_OF_REPO
BRANCH_TO_MERGE_FROM=BRANCH_NAME_TO_MERGE_FROM
BRANCH_TO_MERGE_INTO=BRANCH_NAME_TO_MERGE_INTO_AND_PUSH_UP

# Just a helper method
function yes_prompt 
{
	if [ "$autoOverwrite" = "-f" ]; then
		echo; # just autoyes
	else
		echo -en "${gray}Type \"yes\" to continue: ${clear}"; 
		read key;

		if [[ $key = "yes" ]]; then 
			echo;
		else
		    echo "Warning: \"yes\" was not written, exiting script.";
		    exit 1;
		fi
	fi
}

# Colors are actually wrong..
green='\033[1;32m';
blue='\033[1;33m';
red='\033[1;34m';
red='\033[1;34m';
gray='\033[1;30m';
clear='\033[0m';

# Just a random string for the stash
TEMP_STASH_NAME=$(date | md5)

# Prettify output
echo;
echo;

# Info
echo -e "--------------";
echo -e "${green}QA Dance Script${clear}";
echo -e "--------------";

echo;
echo -e "${blue}Use case${clear}:";
echo -e "${gray}>${clear} You are in the middle of coding and QA wants new stuff that are on development branch. Example after a pull request was merged. This script will then save your current state (stash+current branch), checkout and pull development branch so that you're up to date from origin, do the same for qa branch (pull origin), then merge the new stuff from development branch into the qa branch and push it up. Then it will restore your state (stash+branch). All in less than 30 seconds.";

echo;
echo -e "${blue}This script will${clear}:";
echo -e "${gray}1.${clear} CD to your project folder (${red}$REPO_DIR${clear})";
echo -e "${gray}2.${clear} Stash any temporary work in a new stash";
echo -e "${gray}2.5${clear} Save the current branch name (so we can go back automatically)";
echo -e "${gray}3.${clear} Checkout ${red}$BRANCH_TO_MERGE_FROM${clear} branch";
echo -e "${gray}4.${clear} Pull ${red}$BRANCH_TO_MERGE_FROM${clear} branch to ensure up-to-dateness";
echo -e "${gray}5.${clear} Checkout ${red}$BRANCH_TO_MERGE_INTO${clear} branch";
echo -e "${gray}6.${clear} Pull ${red}$BRANCH_TO_MERGE_INTO${clear} branch to ensure up-to-dateness";
echo -e "${gray}7.${clear} Merge ${red}$BRANCH_TO_MERGE_FROM${clear} INTO ${red}$BRANCH_TO_MERGE_INTO${clear}";
echo -e "${gray}8.${clear} Push ${red}$BRANCH_TO_MERGE_INTO${clear} to ${red}origin/$BRANCH_TO_MERGE_INTO${clear}";
echo -e "${gray}9.${clear} Checkout the previous/saved/working branch from step 2.5";
echo -e "${gray}10.${clear} Apply the saved stash";

echo;
echo;

echo -ne "Confirm each step by typing \"${gray}yes${clear}\" to the next step"; 
echo;
echo;

# Small gap to show it
yes_prompt;


# Step 1, Change directory
echo -e "Current directory is ${red}$(pwd)${clear}";
echo -ne "${blue}Step 1.${clear} CD to ${red}$REPO_DIR${clear}? "; yes_prompt;
cd $REPO_DIR
echo -e "Current directory is ${red}$(pwd)${clear}";

echo; 
echo; 

# Step 2, Stash temp work in a new stash
CURRENT_BRANCH=$(git branch | grep "\*" | sed s/\*\ //);
echo -ne "${blue}Step 2.${clear} Stash (if any) temp work in a new stash named ${red}$TEMP_STASH_NAME${clear} from the current branch ${red}$CURRENT_BRANCH${clear}? "; yes_prompt;
echo -ne "${gray}"
git stash save $TEMP_STASH_NAME
echo -ne "${clear}"
echo;

# Step 2.5, Save current branch 
echo -ne "${blue}Step 2.5${clear} Save current branch name (${red}$CURRENT_BRANCH${clear}) so we can get back "; yes_prompt;
echo;

# Step 3-4, Checkout branch
echo -ne "${blue}Step 3-4${clear} Checkout ${red}$BRANCH_TO_MERGE_FROM${clear} and PULL "; yes_prompt;
echo -e "${gray}Checking out ${red}$BRANCH_TO_MERGE_FROM${clear}"
git checkout $BRANCH_TO_MERGE_FROM
echo -e "${gray}Pulling ${red}origin/$BRANCH_TO_MERGE_FROM${clear}"
git pull
echo -e "${gray}Done.${clear}"
echo;

# Step 5-6, Checkout branch
echo -ne "${blue}Step 5-6${clear} Checkout ${red}$BRANCH_TO_MERGE_INTO${clear} and PULL "; yes_prompt;
echo -e "${gray}Checking out ${red}$BRANCH_TO_MERGE_INTO${clear}";
git checkout $BRANCH_TO_MERGE_INTO;
echo -e "${gray}Pulling ${red}origin/$BRANCH_TO_MERGE_INTO${clear}";
git pull;
echo -e "${gray}Done.${clear}";
echo;

# Step 7, Checkout branch
echo -ne "${blue}Step 7${clear} Merge ${red}$BRANCH_TO_MERGE_FROM${clear} into ${red}$BRANCH_TO_MERGE_INTO${clear} "; yes_prompt;
echo -e "${gray}Merging.${clear}"
git merge $BRANCH_TO_MERGE_FROM
echo -e "${gray}Done.${clear}"
echo;

# Step 8, Checkout branch
echo -ne "${blue}Step 8${clear} Push ${red}$BRANCH_TO_MERGE_INTO${clear} to ${red}origin/$BRANCH_TO_MERGE_INTO${clear} "; yes_prompt;
echo -e "${gray}Pushing.${clear}"
git push
echo -e "${gray}Done.${clear}"
echo;

# Step 9, Checkout old saved
echo -ne "${blue}Step 9${clear} Checkout previous branch ${red}$CURRENT_BRANCH${clear} "; yes_prompt;
git checkout $CURRENT_BRANCH
echo;

# Step 10, Apply old stash
echo -ne "${blue}Step 10${clear} Apply saved (if anything) stash ${red}$TEMP_STASH_NAME${clear} "; yes_prompt;
git stash apply stash^{/$TEMP_STASH_NAME}
echo -e "${blue} --- IF this showed an error, you might have not stashed anything in step 2 (you can scroll up and check)${clear}";
echo;

echo "All done.."