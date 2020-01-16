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
docker stop apache.ftp server.ftp client.ftp web1.ftp web2web3.ftp
docker rm apache.ftp server.ftp client.ftp web1.ftp web2web3.ftp
docker volume rm volume.ftp
docker volume create volume.ftp
docker network rm iphost



#Create network
docker network create --driver overlay --attachable iphost 


#Creates Apache container with our volume, mounted in /usr/local/apache2/htdocs/
docker run -dit --name  apache.ftp -p 80:80  -v volume.ftp:/usr/local/apache2/htdocs/ --network iphost httpd:2.4

#Creates ftp client
docker run -d --name client.ftp -p 5800:5800 -v /docker/appdata/filezilla:/config:rw -v $HOME:/storage:rw --network iphost jlesage/filezilla

#Creates ftp server
docker run -d -p 21:21 -v volume.ftp:/home/vsftpd/admin --name server.ftp --network iphost fauria/vsftpd
#docker cp ./projecte.ftpd/logerror.sh server.ftp:/usr/sbin/run-vsftpd.sh

 
#Creates apache for websites
docker run -dit -p 81:80  --name  web1.ftp --network  iphost  nginx
docker run -dit -p 82:80  --name  web2web3.ftp --network iphost  httpd:2.4

#Create subfolders for each website (web2web3.ftp)
docker exec web2web3.ftp bash -c "cd /usr/local/apache2/htdocs && mkdir web2 web3"

#Copy websites to our servers (web1.ftp and web2web3.ftp)
echo First website directory: ; read web1_dir
echo Second website directory: ; read web2_dir
echo Third website directory: ; read web3_dir
echo General website directory: ; read webgeneral_dir
cd $web1_dir && docker cp . web1.ftp:/usr/share/nginx/html
cd $web2_dir && docker cp . web2web3.ftp:/usr/local/apache2/htdocs/web2
cd $web3_dir && docker cp . web2web3.ftp:/usr/local/apache2/htdocs/web3
cd $webgeneral_dir && docker cp . apache.ftp:/usr/local/apache2/htdocs/

docker exec web2web3.ftp bash -c "cd /usr/local/apache2/htdocs && rm index.html"

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
echo "Your Client FTP's IP Address:" $(docker exec client.ftp hostname -i)
echo
sleep 1
echo "Your Server FTP's IP Address:" $(docker exec server.ftp hostname -I)
sleep 1
echo "Your Server FTP's Info:"
echo 
docker exec server.ftp ./usr/sbin/run-vsftpd.sh
sleep 1
echo
echo "Your Apache's IP Address:" $(docker exec apache.ftp hostname -I)
sleep 1
echo "Your Client Apache's IP Adresses:" $(docker exec web1.ftp hostname -I) $(docker exec web2web3.ftp hostname -I)
echo
echo
echo " ***** You can already access to your Server FTP from Client FTP putting User's "
echo "       login and password. ***** "
echo
echo
echo

 

 






