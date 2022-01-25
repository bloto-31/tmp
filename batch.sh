#! /bin/bash

if [ -z "$1" ] || [ -z "$2" ]
    then
	echo 'Usage: batch.sh path_to_dir format'
	echo 'eg.: batch.sh /tmp csv'
	exit 1
fi

echo "finding/archiving $2 files under $1 older than 1 hour"

cd $1
find . -mmin +60 -type f -name '*.'$2 -print0 | xargs -0 tar -czvf archive_$(date +%Y%m%d).tar.gz | tee ./archive_$(date +%Y%m%d%H%M%S).log
exit 0
