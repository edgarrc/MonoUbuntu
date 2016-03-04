#! /bin/sh
######################################################
# This script is provided as is, use at your own risk
#
# For more information about issues, suggestions, 
# please refer to: https://github.com/edgarrc/MonoUbuntu
#
# You can download a Hello World application to test your installation from:
#
# https://github.com/edgarrc/MonoUbuntu/releases/download/hello/hello.zip
#
# Edgar
######################################################

#----- START

	apt-get -y update
	apt-get -y install wget
	apt-get -y install apache2

#----- STEP 2

	#Add the last official repository
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
	echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | sudo tee -a /etc/apt/sources.list.d/mono-xamarin.list

	apt-get update
	apt-get -y install mono-runtime
	apt-get -y install libapache2-mod-mono
	#apt-get -y install mono-apache-server2

	#Disable apache KeepAlive as recomended by mono-project for production use
	find /etc/apache2/ -name apache2.conf -type f -exec sed -i s/"KeepAlive On"/"KeepAlive Off"/g {} \;
	
	/etc/init.d/apache2 restart

#----- STEP 3

	#Ask for application name
	#echo -n " Enter the name of your ASP.NET application : "
	#read appnameInput
	appnameInput="deolhonarede"

	#Get some templates used for replacement on config files
	wget https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/template-insert-sites.txt
	wget https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/template-insert-webapp.txt

	#Update template variables	
	find ./ -name template-insert-sites.txt -type f -exec sed -i s/"%APPNAME%"/"$appnameInput"/g {} \;
	find ./ -name template-insert-webapp.txt -type f -exec sed -i s/"%APPNAME%"/"$appnameInput"/g {} \;
	
	#Apply to apache default website configuration
	sed -i '/<VirtualHost/r template-insert-sites.txt' /etc/apache2/sites-enabled/000-default.conf

	#Apply to default.webapp	
	sed -i '/<apps>/r template-insert-webapp.txt' /etc/mono-server4/debian.webapp
	
	#Remove templates
	rm template-insert-sites.txt
	rm template-insert-webapp.txt 
	 
	#Create directory for application
	mkdir -p /var/www/html/$appnameInput
	chown -R www-data:www-data /var/www

	/etc/init.d/apache2 restart
