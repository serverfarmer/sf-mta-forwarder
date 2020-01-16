#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.install


if [ "$SMTP" = "true" ]; then
	echo "install sf-mta-relay extension instead of sf-mta-forwarder"
	exit 0
fi

DOMAIN=`external_domain`
mach=`uname -m`

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

elif [ "$OSTYPE" = "amazon" ]; then
	/opt/farm/ext/packages/utils/install.sh openssl-devel mailx
	/opt/farm/ext/packages/special/install-rpm-from-file.sh ssmtp /opt/farm/ext/mta-forwarder/support/packages/ssmtp-2.64-14.amzn1.$mach.rpm
	/opt/farm/ext/packages/utils/uninstall.sh sendmail
	/opt/farm/ext/mta-forwarder/configure-ssmtp.sh /etc/ssmtp

elif [ "$OSVER" = "redhat-rhel7" ] || [ "$OSVER" = "redhat-centos7" ] || [ "$OSVER" = "redhat-oracle7" ]; then
	/opt/farm/ext/packages/utils/install.sh openssl-devel mailx
	/opt/farm/ext/packages/special/install-rpm-from-file.sh ssmtp /opt/farm/ext/mta-forwarder/support/packages/ssmtp-2.64-14.el7.$mach.rpm
	/opt/farm/ext/mta-forwarder/configure-ssmtp.sh /etc/ssmtp

elif [ "$OSVER" = "redhat-rhel8" ]; then
	/opt/farm/ext/packages/utils/install.sh openssl-devel mailx
	/opt/farm/ext/packages/special/install-rpm-from-file.sh ssmtp /opt/farm/ext/mta-forwarder/support/packages/ssmtp-2.64-14.el8.$mach.rpm
	/opt/farm/ext/mta-forwarder/configure-ssmtp.sh /etc/ssmtp

elif [ "$OSVER" = "debian-buster" ]; then
	/opt/farm/ext/mta-forwarder/setup-lsb-invalid-mta.sh  # ...and use ssmtp from sf-binary-ssmtp extension
	/opt/farm/ext/packages/utils/install.sh bsd-mailx
	/opt/farm/ext/mta-forwarder/configure-ssmtp.sh /etc/ssmtp

elif [ "$OSTYPE" = "debian" ]; then
	/opt/farm/ext/packages/utils/install.sh ssmtp bsd-mailx
	/opt/farm/ext/mta-forwarder/configure-ssmtp.sh /etc/ssmtp

elif [ "$OSTYPE" = "freebsd" ]; then
	/opt/farm/ext/packages/utils/install.sh ssmtp
	/opt/farm/ext/mta-forwarder/configure-ssmtp.sh /usr/local/etc/ssmtp

	remove_link /etc/mail/mailer.conf
	save_original_config /etc/mail/mailer.conf
	install_copy $common/freebsd-mailer.conf /etc/mail/mailer.conf
fi
