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
		/opt/farm/ext/packages/utils/uninstall.sh patterns-openSUSE-minimal_base-conflicts
		/opt/farm/ext/packages/utils/install.sh postfix mailx
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

elif [ "$OSVER" = "redhat-rhel8" ]; then
	/opt/farm/ext/packages/utils/install.sh openssl-devel mailx

	echo "checking for rpm package ssmtp"
	if ! rpm --quiet -q ssmtp; then
		echo "installing package ssmtp"
		mach=`uname -m`
		rpm -i /opt/farm/ext/mta-forwarder/support/packages/ssmtp-2.64-14.el8.$mach.rpm
	fi

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/ssmtp/ssmtp.conf

elif [ "$OSVER" = "debian-buster" ]; then
	/opt/farm/ext/mta-forwarder/setup-lsb-invalid-mta.sh
	/opt/farm/ext/packages/utils/install.sh bsd-mailx

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/ssmtp/ssmtp.conf

elif [ "$OSTYPE" = "debian" ]; then
	/opt/farm/ext/packages/utils/install.sh ssmtp bsd-mailx

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/etc/ssmtp/ssmtp.conf

elif [ "$OSTYPE" = "freebsd" ]; then
	/opt/farm/ext/packages/utils/install.sh ssmtp

	echo "setting up ssmtp"
	cat $common/ssmtp.tpl |sed -e s/%%host%%/$HOST/g -e s/%%domain%%/$DOMAIN/g -e s/%%smtp%%/$SMTP/g >/usr/local/etc/ssmtp/ssmtp.conf

	remove_link /etc/mail/mailer.conf
	save_original_config /etc/mail/mailer.conf
	install_copy $common/freebsd-mailer.conf /etc/mail/mailer.conf
fi
