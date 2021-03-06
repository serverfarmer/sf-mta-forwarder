#!/bin/sh
# Install sSMTP provided by Server Farmer on Debian/Ubuntu/clones,
# where ssmtp system package is no longer provided


if [ -f /etc/debian_version ]; then
	/opt/farm/ext/packages/utils/install.sh libgnutls-openssl27
	/opt/farm/ext/packages/utils/uninstall.sh postfix exim4 exim4-daemon-light exim4-base exim4-config
	/opt/farm/scripts/setup/extension.sh sf-binary-ssmtp

	echo "checking for debian package lsb-invalid-mta"
	if [ "`dpkg -l lsb-invalid-mta 2>/dev/null |grep ^ii`" = "" ] \
	&& [ "`dpkg -l ssmtp 2>/dev/null |grep ^ii`" = "" ]; then
		echo "installing lsb-invalid-mta from provided deb package"
		dpkg -i /opt/farm/ext/mta-forwarder/support/packages/lsb-invalid-mta_4.1+Debian13+nmu1_all.deb
	fi

	SSMTP=`/opt/farm/ext/binary-ssmtp/wrapper/get-ssmtp-binary-name.sh`

	if [ "$SSMTP" != "" ] && [ "`dpkg -l lsb-invalid-mta 2>/dev/null |grep ^ii`" != "" ]; then
		echo "installing ssmtp in provided version on top of lsb-invalid-mta"
		mkdir -p /etc/ssmtp

		if [ -s /etc/revaliases ] && [ ! -f /etc/ssmtp/revaliases ]; then
			mv /etc/revaliases /etc/ssmtp
		fi

		if [ ! -f /etc/ssmtp/revaliases ]; then
			cp /opt/farm/ext/mta-forwarder/templates/revaliases /etc/ssmtp
		fi

		echo "replacing sendmail with ssmtp wrapper script"
		rm -f /usr/sbin/sendmail
		echo "#!/bin/sh" >/usr/sbin/sendmail
		echo "/usr/sbin/ssmtp \$@" >>/usr/sbin/sendmail
		chmod 0755 /usr/sbin/sendmail

		echo "creating ssmtp symbolic links"
		ln -sf $SSMTP /usr/sbin/ssmtp
		ln -sf /usr/sbin/ssmtp /usr/bin/mailq
		ln -sf /usr/sbin/ssmtp /usr/bin/newaliases
		ln -sf /usr/sbin/sendmail /usr/lib/sendmail

		if [ ! -s /etc/debsums-ignore ] || ! grep -q /usr/sbin/sendmail /etc/debsums-ignore; then
			echo "/usr/sbin/sendmail" >>/etc/debsums-ignore
		fi
	fi
fi
