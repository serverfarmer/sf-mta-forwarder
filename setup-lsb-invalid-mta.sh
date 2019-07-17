#!/bin/sh
# Install sSMTP provided by Server Farmer on Debian/Ubuntu/clones,
# where ssmtp system package is no longer provided


if [ -f /etc/debian_version ]; then
	/opt/farm/ext/packages/utils/install.sh libgnutls-openssl27

	echo "checking for debian package lsb-invalid-mta"
	if [ "`dpkg -l lsb-invalid-mta 2>/dev/null |grep ^ii`" = "" ] \
	&& [ "`dpkg -l ssmtp 2>/dev/null |grep ^ii`" = "" ] \
	&& [ "`dpkg -l postfix 2>/dev/null |grep ^ii`" = "" ]; then

		echo "installing lsb-invalid-mta from provided deb package"
		dpkg -i /opt/farm/ext/mta-forwarder/support/packages/lsb-invalid-mta_4.1+Debian13+nmu1_all.deb

		if [ "`dpkg -l lsb-invalid-mta 2>/dev/null |grep ^ii`" = "" ]; then
			echo "installing ssmtp in provided version"
			mkdir -p /etc/ssmtp

			if [ -s /etc/revaliases ] && [ ! -f /etc/ssmtp/revaliases ]; then
				mv /etc/revaliases /etc/ssmtp
			fi

			if [ ! -f /etc/ssmtp/revaliases ]; then
				cp /opt/farm/ext/mta-forwarder/templates/revaliases /etc/ssmtp
			fi

			if [ "`uname -m`" = "x86_64" ]; then
				arch="amd64"
			else
				arch="i386"
			fi

			echo "creating ssmtp symbolic links"
			ln -sf /opt/farm/ext/mta-forwarder/support/ssmtp_debian/ssmtp.$arch /usr/sbin/ssmtp

			ln -sf /usr/sbin/ssmtp /usr/sbin/mailq
			ln -sf /usr/sbin/ssmtp /usr/sbin/newaliases
			ln -sf /usr/sbin/ssmtp /usr/sbin/sendmail
			ln -sf /usr/sbin/sendmail /usr/lib/sendmail
		fi
	fi
fi
