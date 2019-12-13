#!/bin/bash

echo
sleep 1
echo " *"
sleep 1
echo " *"
sleep 1
echo " *** Welcome to Projecte.ftpd script made by haykzaryan ***"
sleep 2
echo " *** Have a nice day! ***"
echo
echo

#Creates volume (deletes the old volume and containers in case if you have already executed the script 1 or more times)
docker stop apache.ftp server.ftp client.ftp web1.ftp web2.ftp web3.ftp
docker rm apache.ftp server.ftp client.ftp web1.ftp web2.ftp web3.ftp
docker volume rm volume.ftp
docker volume create volume.ftp

#Creates ftp server
docker run -d -p 21:21 -v volume.ftp:/home/vsftpd/myuser --name server.ftp -e FTP_USER=cliente -e FTP_PASS=clientji* fauria/vsftpd
 
#Creates ftp client
docker run -d --name client.ftp -p 5800:5800 -v /docker/appdata/filezilla:/config:rw -v $HOME:/storage:rw jlesage/filezilla

#Creates Apache container with our volume, mounted in /usr/local/apache2/htdocs/
docker run -dit --name  apache.ftp  -v volume.ftp:/usr/local/apache2/htdocs/ httpd:2.4

#Creates apache for websites
docker run -dit --name  web1.ftp httpd:2.4
docker run -dit --name  web2.ftp httpd:2.4
docker run -dit --name  web3.ftp httpd:2.4

# INFO
echo
echo
echo
echo
echo
echo
echo " *****   IMPORTANT!   *****"
echo
sleep 1
echo " --> Files of your host's directory [/home/$(whoami)], it shows in "
echo " /storage (Host directory has been mounted in Client FTP's /storage directory.) "  
echo
sleep 1
echo "Your Client FTP's IP Address:" $(docker exec client.ftp for i in $(echo $(ip a | grep 172)); do echo $i; done | grep /16)
echo
sleep 1
echo "Your Server FTP's IP Address:" $(docker exec server.ftp hostname -I)
sleep 1
echo "Your Client FTP's User: cliente"
sleep 1
echo "Your Client FTP's User's password: clientji*"
sleep 1
echo
sleep 1
echo "Your Apache's IP Address:" $(docker exec apache.ftp hostname -I)
echo
echo
echo " ***** You can already access to your Server FTP from Client FTP putting User's "
echo "       login and password. ***** "
echo
echo
echo

 

 






