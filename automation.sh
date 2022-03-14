#!/bin/bash
sudo apt -y update

name="Pratik"
s3_bucket="upgrad-pratik"

if [ "dpkg-query -W apache2 | awk {'print $1'} != "apache2"" ]; then
    sudo apt-get -y install apache2
fi

if [ "systemctl show -p ActiveState --value apache2 != "active"" ]; then
    sudo service apache2 start
fi

webServiceStatus=`service apache2 status | grep 'apache2.service; enabled' | wc -l`
if [ $webServiceStatus -ne 1 ]; then
    sudo systemctl enable apache2
fi

datetime=$(date '+%m%d%Y-%H%M%S')
tarfile=$name-httpd-logs-$datetime.tar
cd /var/log/apache2/
sudo tar -cvf /tmp/$tarfile *.log
cd ~
aws s3 cp /tmp/$tarfile s3://${s3_bucket}/$tarfile

fileSize=`ls /tmp/$tarfile -sh | awk {'print $1'}`
file_ext=$(echo $tarfile |awk -F . '{if (NF>1) {print $NF}}')
if [ ! -f /var/www/html/inventory.html ]; then
    touch /var/www/html/inventory.html
	echo -e '\tLog Type\tDate Created\tType\tSize' >> /var/www/html/inventory.html
fi
echo -e '\thttpd-logs\t'$datetime'\t'$file_ext'\t'$fileSize >> /var/www/html/inventory.html

if [ ! -f /etc/cron.d/automation ]; then
    touch /etc/cron.d/automation
    echo '0 0 * * * root /root/Automation_Project/automation.sh' >> /etc/cron.d/automation
fi
