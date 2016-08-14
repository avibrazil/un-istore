#!/bin/sh

export SEEK_FOR_USERNAME=${1:-iTunes Store}

export LC_COLLATE=C
export LC_ALL=C
export LANG=C

find . -name "*m4a" | sort | while read f; do
	if grep -m 1 -q "${SEEK_FOR_USERNAME}" "$f"; then
		echo "Going through «$f»"
		exiftool -UserID -TransactionID -ItemID "$f" | grep -q -v "0xffffffff" && echo && echo "Dirty «$f»"
	fi
done