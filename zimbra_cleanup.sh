#!/bin/bash

function help {
	echo 'This script is a much more incremental way of removing large folders from Zimbra accounts.'
	echo 'A Username/Email & Folder path is required'
	echo ''
	echo 'First argument is the username (ex user@domain.com)'
	echo 'Second argument is the folder path (ex "/Inbox/SomeFolder")'
	echo ''
	echo 'Syntax: zimbra_cleanup.sh <username> <folder>'
	echo 'Example: zimbra_cleanup.sh "user@domain.com" "/Inbox/SomeFolder"'
}


USER=$1
FOLDER=$2
COUNT=500

[[ ! $USER ]] && help && exit 2
[[ ! $FOLDER ]] && help && exit 3

echo "Removing all messages from \"${FOLDER}\" in account \"${USER}\""
echo "Initial Folder Information:"
/opt/zimbra/bin/zmmailbox -v -z -m "${USER}" gf "${FOLDER}"

MESSAGEIDS=$(for id in $(/opt/zimbra/bin/zmmailbox -z -m "${USER}" search -t message -l ${COUNT} "in:${FOLDER}"|awk '{print $2}'| sed -e '1,4d');do echo -n "${id},";done|sed 's/,$//')
while [ $MESSAGEIDS ]; do
	/opt/zimbra/bin/zmmailbox -z -m "${USER}" dm "${MESSAGEIDS}"
	echo -n "."
	MESSAGEIDS=$(for id in $(/opt/zimbra/bin/zmmailbox -z -m "${USER}" search -t message -l ${COUNT} "in:${FOLDER}"|awk '{print $2}'| sed -e '1,4d');do echo -n "${id},";done|sed 's/,$//')
done

echo "Final Folder Information:"
/opt/zimbra/bin/zmmailbox -v -z -m "${USER}" gf "${FOLDER}"
