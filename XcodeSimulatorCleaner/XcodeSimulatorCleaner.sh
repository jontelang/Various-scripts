#!/bin/bash

# Print size of folders for each simulator
$(du -h -d 1 -c ~/Library/Developer/CoreSimulator/Devices/ > ~/Desktop/sizes-before.txt);
echo "Writing data about before sized to ~/Desktop/sizes-before.txt"

# Also just quickly show the total
echo $(du -h -d 1 -c ~/Library/Developer/CoreSimulator/Devices/ | grep total);

# Get all simulators and extract their IDs
arrayOfSims=$(instruments -s devices 2>/dev/null | grep \\[[A-Z0-9] | grep iP | awk -F'[()]' '{print $3}' | sed s/\ \\[// | sed s/\\]// | grep -v \+)

# Run the xcode tools for erasing apps on a simulator
for sim in $arrayOfSims;
	do
		echo "Running 'xcrun simctl erase $sim'"
		$(xcrun simctl erase $sim)
	done

# Print size of folders for each simulator
$(du -h -d 1 -c ~/Library/Developer/CoreSimulator/Devices/ > ~/Desktop/sizes-after.txt);
echo "Writing data about before sized to ~/Desktop/sizes-after.txt"

# Also just quickly show the total
echo $(du -h -d 1 -c ~/Library/Developer/CoreSimulator/Devices/ | grep total);