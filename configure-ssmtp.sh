#!/bin/sh
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom

DOMAIN=`external_domain`
path=$1

if [ "$path" != "" ] && [ -d $path ]; then
	echo "setting up ssmtp"
	cat /opt/farm/ext/mta-forwarder/templates/ssmtp.tpl |sed \
		-e s/%%host%%/$HOST/g \
		-e s/%%domain%%/$DOMAIN/g \
		-e s/%%smtp%%/$SMTP/g \
		>$path/ssmtp.conf
else
	echo "error: ssmtp configuration directory not found"
fi
