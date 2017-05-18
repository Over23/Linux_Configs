#################################################################################
#                                                                               #
# TEST QUESTIONS ARE ON ADDRESS [only actual]                                   #
# https://raw.githubusercontent.com/Over23/Linux_Configs/master/test.txt        #
# -----------------------------------------------------------------------       #
# DOWNLOAD IT AND 'N JOY                                                        #
#                                                                               #
#################################################################################

#!/bin/bash -x
### automatic deploy script to create origial machine befor the tests
### run as root
### this script should not be given to tested person, before test, SPOILERS HEAVYLY INCLUDED 
### created by Tomas Petru, 5/18/2017

### preparation steps and notes
### ===========================
# install genisoimage to create ISO to mount later [in case it was not already created]
# yum install genisoimage -y

### ===========================
###  HAND OVER TO TESTED PERSON  
### ===========================

###  server info
### -------------
#username: idontcare
#passwd : iam too lame
#root passwd: this is root password
#key SSH format, they will need to convert it to putty format; careful, every line is hashed

#-----BEGIN RSA PRIVATE KEY-----
xxxxxxxxxxxxxxx
#-----END RSA PRIVATE KEY-----

# test questions
# --------------
# rules of test: you can google/search, you can use man or your notes
# timeframe is 2 hours

# 1] download questions according message of the day to the server, under every question write exactly what have you did, what was problem, .... 
#  just report. BOTH, commandline and own words are mandatory
# 2] configure server to allow ssh as root by key
# 3] configure sudo to allow user idontcare to be able to use sudo without password for all commands
#    3.1] why to edit sudoers by something else than standard TXT editor and by what?
#    3.2] what is difference between su and sudo
# 4] start Apache - find what is the problem
# 5] delete files in /home/idontcare/delete_me/; but only delete_me*.to.del in range 0003 to 0105, other should stay intact
# 6] customer is complaining, there are no files in /cdrom directory and he deleted nothing and it stopped to work recently, normally
#   after server reboot some files are presented there
# 7] find biggest files on / filesystem, if something is mounted, do not look there
# 8] there is huge file in /home/idontcare find it and delete it
# 9] do sha256 of iso in /home/idontcare : ad30b003a5face0477177d4980c5c26ba75df21de069612d9fa59ac3ab613aeb
#   9.1] what is reason we do use tools for CRC check?
#   9.2] if you do sha256 to that file and it does not fit with one from example, what does it mean?
#   9.3] do sha512 of same iso, and explain what is diffrence, why?
# 10] can you imagine how to generate (pseudo)random 10 characters long sting [that could be e.g. used as passowrd]
# 11] Every day at 18:15 and 6:15 run following: check how much space is consumed on all disks and save the output to 
#   /tmp/diskfree-<date-timestamp>.log


### ================================
###  HAND OVER TO TESTED PERSON  END
### ================================

# ToDo:
# =====
## to ~/.bashrc, usefull to watch what tested person is doing on other console
#if $(screen -ls | grep -q pts); then  screen -x; else screen -RU; fi

# backing up, steps for admin of test
# ===================================
# copy of this script to backup
# cp /home/idontcare/deploy.sh /tmp/backup_of_test_machine/deploy.sh
# backup fstab with cdrom mount [not needed, just for sure]
# cp /etc/fstab /tmp/backup_of_test_machine/fstab
# backup of cdrom.iso not need to create it again
# cp /home/idontcare/cdrom.iso /tmp/backup_of_test_machine/cdrom.iso
# cnage ownership uf backup directory not to allow idontcare to read its contents
# chown root:root /tmp/backup_of_test_machine/
# chmod 700 /tmp/backup_of_test_machine/
# backup sudoers
# cp /etc/sudoers /tmp/bacup_of_test_machine/sudoers
# backup motd
# cp /etc/motd /tmp/backup_of_test_machine/
# backed up .bashrc with screen for user idontcare
# cp /home/idontcare/.bashrc /tmp/backup_of_test_machine/

# =================================
# cleaning after previous user
# =================================
# remove telnet if its presented
yum remove telnet -y
# delete bash history
rm -f /home/idontcare/.history /root/.history


# APACHE PROBLEMS
# ---------------
# kill all possible apaches
killall httpd
# kill possible netcat running on port 80
kill -9 $(ps aux | grep 'nc -lk 80'| grep -v grep | awk '{print $2}')
# copy broken config file from backup
cp /tmp/backup_of_test_machine/httpd.conf /etc/httpd/conf/httpd.conf
# start new netcat on pot 80
nc -lk 80 &


# to delete only files 3-99
# -------------------------
# delete directory where files should be deleted in bulk
rm -rf /home/idontcare/delete_me
# create that dir again for fres use
mkdir /home/idontcare/delete_me/
# create 1000 files
touch /home/idontcare/delete_me/delete_me{0001..1000}.to.del

# configure server to allow root ssh login
# ----------------------------------------
# clean allowd key and whole ssh dir
rm -rf /root/.ssh
# return sshd_config without root able to login
cp /tmp/bacup_of_test_machine/sshd_config /etc/ssh/sshd_config
# restart sshd service without user root to be able to login
service sshd restart

# allow your user to perform sudo
# --------------------------------
# return back sudoers without user idontcare is able to do sudo
cp /tmp/bacup_of_test_machine/sudoers /etc/sudoers

# mount ISO
# ---------
umount /cdrom

# delete mount point /cdrom
### LAST command, deploy.sh will be set as read only
chmod 400 /home/idontcare/deploy.sh

############################################################################# temporary removed, run it when real test needed
# problem with huge file, invent better, that dd is lame
# -------------------------------------------------------
## keep in mind, that this will run long, and will consume disk space, which is original purpose of script, but still

# create file and delete it, just to look for it by lsof | grep delete
# dd if=/dev/urandom of=/home/idontcare/divny_soubor bs=2048 count=10000000 &
# sleep 6m
# rm -f /home/idontcare/divny_soubor


#### ==========
#### NOTES for test admin, not part of test itself
#### ==========
### to mount iso
# mount -o loop /home/idontcare/cdrom.iso /cdrom/


# create ISO cdrom.iso from this directory
# mkisofs -o /home/idontcare/cdrom.iso /home/idontcare/delete_me/

# install and damage httpd
# yum install httpd
# vim /etc/httpd/conf/httpd.conf
# ideally damage something like DocumetRoot "/var/www/html" -> /var/www/Html"

# example of answer of question 10]
# example anser: date | sha256sum | cut -c 1-10
# answer to 11]
# 15 6,18 * * df –h >/tmp/diskfree-$(date +"\%Y-\%m-\%d").log
# selinux problem with /root/.ssh solution
# restorecon -R -v /root/.ssh

