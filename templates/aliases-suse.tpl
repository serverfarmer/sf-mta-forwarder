# This is the aliases file - it says who gets mail for whom.
#
# >>>>>>>>>>      The program "newaliases" will need to be run
# >> NOTE >>      after this file is updated for any changes
# >>>>>>>>>>      to show through to sendmail.
#

# It is probably best to not work as user root and redirect all
# email to "root" to the address of a HUMAN who deals with this
# system's problems. Then you don't have to check for important
# email too often on the root account.
# The "\root" will make sure that email is also delivered to the
# root-account, but also forwared to the user "joe".
#root:		joe, \root

# Basic system aliases that MUST be present.
postmaster:	root
mailer-daemon:	postmaster

# amavis
virusalert:	root

# General redirections for pseudo accounts in /etc/passwd.
administrator:	root
daemon:		root
lp:		root
news:		root
uucp:		root
games:		root
man:		root
at:		root
postgres:	root
mdom:		root
amanda:		root
ftp:		root
wwwrun:		root
squid:		root
msql:		root
gnats:		root
nobody:		root
# "bin" used to be in /etc/passwd
bin:		root

# Further well-known aliases for dns/news/ftp/mail/fax/web/gnats.
newsadm:	news
newsadmin:	news
usenet:		news
ftpadm:		ftp
ftpadmin:	ftp
ftp-adm:	ftp
ftp-admin:	ftp
hostmaster:	root
mail:		postmaster
postman:	postmaster
post_office:	postmaster
# "abuse" is often used to fight against spam email
abuse:		postmaster
spam:		postmaster
faxadm:		root
faxmaster:	root
webmaster:	root
gnats-admin:	root
mailman:	root
mailman-owner:	mailman

# mlmmj needs only one alias to function; this is with a mailinglist in
# /var/spool/mlmmj/myownlist (remember full path):
# myownlist: "| /usr/bin/mlmmj-recieve -L /var/spool/mlmmj/myownlist"

# Majordomo can be used to have mailinglists on your site.
#majordomo:		"|/usr/lib/majordomo/wrapper majordomo"
#owner-majordomo:	root,
#majordomo-owner:	root,

# sample entry for a majordomo mailing-list called "test"
# read /usr/doc/packages/majordomo/README.linux for more information
# replace "test" with a new name and put the administrator into
# the "owner-test" alias instead of "root".
#
#test:			"|/usr/lib/majordomo/wrapper resend -l test test-outgoing"
#test-outgoing:		:include:/var/lib/majordomo/lists/test
#test-request:		"|/usr/lib/majordomo/wrapper majordomo -l test"
#test-approval:		owner-test,
#owner-test-outgoing:	owner-test,
#owner-test-request:	owner-test,
#owner-test:		root,
#
# if you have bulk_mailer installed, you can replace the above
# "test-outgoing" line with the following:
#test-outgoing:		"|/usr/bin/bulk_mailer owner-test@host.com /var/lib/majordomo/lists/test"
#

# Person who should get root's mail
root: %%host%%@%%domain%%

# na ten alias maja byc wysylane wszystkie maile
# z crona - nalezy go dopisac do /etc/crontab
# i w crontabach poszczegolnych uzytkownikow
cron-rcpt: cron-%%host%%@%%domain%%
