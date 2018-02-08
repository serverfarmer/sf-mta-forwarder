#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.install


if [ "$SMTP" = "true" ]; then
	echo "install sf-mta-relay extension instead of sf-mta-forwarder"
	exit 0
fi

DOMAIN=`external_domain`

common=/opt/farm/ext/mta-forwarder/templates
base=$common/$OSVER

if [ -f $base/postfix.tpl ]; then

	if [ "$OSTYPE" = "netbsd" ]; then
		ln -sf /etc/mail/aliases /etc/aliases
	else
		/opt/farm/ext/repos/utils/uninstall.sh patterns-openSUSE-minimal_base-conflicts
		/opt/farm/ext/repos/utils/install.sh postfix
		/opt/farm/ext/repos/utils/install.sh mailx
	fi

	save_original_config /etc/postfix/main.cf

	echo "setting up postfix"
	cat $base/postfix.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/postfix/main.cf

	echo "setting up mail aliases"
	SHORT="${HOST%%.*}"
	cat $common/aliases-$OSTYPE.tpl |sed -e s/%%host%%/$SHORT/g -e s/%%domain%%/$DOMAIN/g >/etc/aliases
	newaliases

	if [ "$OSTYPE" = "netbsd" ]; then
		/etc/rc.d/postfix reload
	elif [ "$OSTYPE" = "suse" ]; then
		service postfix restart
	else
		service postfix reload
	fi

elif [ "$OSTYPE" = "debian" ]; then
	/opt/farm/ext/repos/utils/install.sh ssmtp
	/opt/farm/ext/repos/utils/install.sh bsd-mailx

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/ssmtp/ssmtp.conf

elif [ "$OSTYPE" = "freebsd" ]; then
	/opt/farm/ext/repos/utils/install.sh ssmtp

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/usr/local/etc/ssmtp/ssmtp.conf

	remove_link /etc/mail/mailer.conf
	save_original_config /etc/mail/mailer.conf
	install_copy $common/freebsd-mailer.conf /etc/mail/mailer.conf
fi
