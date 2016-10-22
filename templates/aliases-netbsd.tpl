#
#  Aliases in this file will NOT be expanded in the header from
#  Mail, but WILL be visible over networks or from /usr/bin/mail.
#
#	>>>>>>>>>>	The program "newaliases" must be run after
#	>> NOTE >>	this file is updated for any changes to
#	>>>>>>>>>>	show through to sendmail.
#

# Basic system aliases -- these MUST be present.
MAILER-DAEMON: postmaster
postmaster: root

# General redirections for pseudo accounts.
toor:		root
daemon:		root
bin:		root
games:		root
postfix:	postmaster
named:		root
ntpd:		root
sshd:		root
nobody:		root

# Well-known aliases -- these should be filled in!
# root:
# operator:

# Standard aliases defined by rfc2142
# address to report network abuse (like spam)
abuse:		postmaster
# reports of network infrastructure difficulties
noc:		root
# address to report security problems
security:	root
# DNS administrator (DNS SOA records should use this)
hostmaster:	root
# Usenet news service administrator
usenet:		root
news:		usenet
# http/web service administrator
webmaster:	root
www:		webmaster
# UUCP service administrator
uucp:		root
# FTP administrator (especially anonymous FTP)
ftp:		root

# don't enable this.
# decode:	/dev/null

# uncomment this for msgs(1):
# msgs: "|/usr/bin/msgs -s"


# Person who should get root's mail
root: %%host%%@%%domain%%

# na ten alias maja byc wysylane wszystkie maile
# z crona - nalezy go dopisac do /etc/crontab
# i w crontabach poszczegolnych uzytkownikow
cron-rcpt: cron-%%host%%@%%domain%%
