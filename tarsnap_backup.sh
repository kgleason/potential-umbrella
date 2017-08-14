#!/usr/bin/env bash

TESTOPT=""
DEBUG=0

# Add any directories to always be ignored to this variable
EXCL="--exclude \"/home/chrx\""

# Add any directories to always be backed up to this variable
BDIR="/etc"

# A list of directories to be ignored within a given home directory
IGN_DIR=".steam .cache steam .minecraft .local/share"

# Process command line parameters
while getopts ":t:d" opt; do
	case $opt in
		t)
			TESTOPT="--dry-run -v"
			;;
		d)
			TESTOPT="--dry-run -v"
			DEBUG=1
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
			;;
	esac
done

TARSNAP=/usr/bin/tarsnap

DATE=$(date +%Y-%m-%d_%H-%M-%S)
HOST=$(uname -n)

# Process each home directory
for H in $(ls /home/); do

	# Exclude some directories for each user
	for I in ${IGN_DIR}; do
		EXCL="${EXCL} --exclude \"/home/${H}/${I}\""
	done

	# Find any files over 1GB in size, and exclude them
	for LF in $(find /home/${H} -type f -size +1024M); do
		if [ ${DEBUG} -eq 1 ]; then
			echo "Found Large File: ${LF}"
		fi
		EXCL="${EXCL} --exclude \"${LF}\""
	done

	# Add this directory to the ones to be backed up
	BDIR="${BDIR} /home/${H}"
done


if [ ${DEBUG} -eq 1 ]; then
	echo "${TARSNAP} -c ${TESTOPT} -f ${HOST}-${DATE} ${EXCL} ${BDIR}"
else
	${TARSNAP} -c ${TESTOPT} -f ${HOST}-${DATE} ${EXCL} ${BDIR} /etc
fi
