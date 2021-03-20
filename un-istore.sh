#!/bin/bash

#########################################################################################
# Cirugicaly overwrite iTunes Store tags and data that might identify the owner of the
# music files. Operates recursively on all M4A files that match the user name passed in
# the command line.
# 
# Run it like this:
#
#    un-istore.sh "The User Name" "theuserid@email.com"
#
# Tested only on Linux, but might work wherever you have Bash, Perl and Perl-Env. To use
# it on Fedora Linux, install Perl-Env first, like this:
#
#    dnf install perl-Env
#
# Avi Alkalay <avi at unix dot sh>
# Brazil 2016-08-13
# Licence: LGPL v3
#########################################################################################

# Operate in binary mode so avoid Unicode interference, and increase speed
export LC_COLLATE=C
export LC_ALL=C
export LANG=C


# Get user name and ID from command line
export SEEK_FOR_USERNAME=${1:-iTunes Store}
export SEEK_FOR_USERID=${2:-iTunes Store}

# Define new anonymous user names with the length of original user names
NEW_USERNAME="iTunes Store"
NEW_USERNAME=`printf "$NEW_USERNAME%${#SEEK_FOR_USERNAME}s"`
export NEW_USERNAME=${NEW_USERNAME:0:${#SEEK_FOR_USERNAME}}
NEW_USERID="iTunes Store"
NEW_USERID=`printf "$NEW_USERID%${#SEEK_FOR_USERID}s"`
export NEW_USERID=${NEW_USERID:0:${#SEEK_FOR_USERID}}

# Just show what is going to happen
echo "old: “$SEEK_FOR_USERNAME”   •   “$SEEK_FOR_USERID”
new: “$NEW_USERNAME”   •   “$NEW_USERID”" >&2



# Do it, recursively...
find . -name "*m4a" | sort | while read f; do
	if grep -m 1 -q "${SEEK_FOR_USERNAME}" "$f"; then
		echo "Processing «$f»"
		
		perl -mEnv=SEEK_FOR_USERNAME,NEW_USERNAME,SEEK_FOR_USERID,NEW_USERID -i -e '
				undef $/;
				$_=<>;
		
				# User ID
				s/user.{4}(.{4})cert/user\xFF\xFF\xFF\xFF$1cert/s;
		
				# User Name in 2 instances
				s/name$SEEK_FOR_USERNAME/name$NEW_USERNAME/;
				s/ownr(.{4})data(.{8})$SEEK_FOR_USERNAME/ownr$1data$2$NEW_USERNAME/s;
		
				# Apple Store Account
				s/apID(.{4})data(.{8})$SEEK_FOR_USERID/apID$1data$2$NEW_USERID/s;
		
				# Transaction ID
				s/tran.{4}(sing|song)/tran\xFF\xFF\xFF\xFF$1/s;
		
				# Item ID
				# This doesnt need removal, its not personal info
				# s/song.{4}tool/song\xFF\xFF\xFF\xFFtool/s;
		
				# Apple Store Catalog ID
				# Not sure if this needs removal
				# s/cnID(.{4})data(.{8}).{4}/cnID$1data$2\xFF\xFF\xFF\xFF/s;
				
				print;
		' "$f"
	else
		echo "Skipping «$f»"
	fi
done
