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

	if [ "$OSTYPE" = "suse" ]; then
		uninstall_rpm patterns-openSUSE-minimal_base-conflicts
		install_suse postfix
		install_suse mailx
	else
		install_rpm postfix
		install_rpm mailx
	fi

	save_original_config /etc/postfix/main.cf

	echo "setting up postfix"
	cat $base/postfix.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/postfix/main.cf

	echo "setting up mail aliases"
	cat $common/aliases-$OSTYPE.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g >/etc/aliases
	newaliases

	if [ "$OSTYPE" = "suse" ]; then
		service postfix restart
	else
		service postfix reload
	fi

elif [ "$OSTYPE" = "debian" ]; then
	install_deb ssmtp
	install_deb bsd-mailx

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/ssmtp/ssmtp.conf

elif [ "$OSTYPE" = "freebsd" ]; then
	install_pkg ssmtp

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/usr/local/etc/ssmtp/ssmtp.conf

	save_original_config /etc/mail/mailer.conf
	install_link $common/freebsd-mailer.conf /etc/mail/mailer.conf
fi
