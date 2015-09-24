#! /bin/sh
######################################################
# This script is provided as is, use at your own risk
#
# For more information about issues, make suggestions, changes
# bugs etc, please refer to: https://github.com/edgarrc/MonoUbuntu
#
# Edgar
######################################################

#Helper function to ask for continue or skipt
askcs ()  {
  echo  -n " - Continue or skip? (c/s) [c]:"
  read resp

  while [ "1" = "1" ]
  do
    if [ "$resp" = '' ];
    then
      resp="y"
      break
    else
      case $resp in
        y | Y | c | C) 
           resp="y";
           break;;
        s | S ) 
		   resp="n";
	       break;;
        *)
           echo -n 'Wrong answer, type again:';
           read resp;
	   continue;;
       esac
    fi
  done
}

#----- STEP 0

echo ""
echo "##INF: ----------------------------------------------"
echo "##INF: Mono/apache - Ubuntu install"
echo "##INF:"
echo "##INF: - Do not continue if mono or apache is already installed"
echo "##INF: - Must be executed as root (sudo)"
echo "##INF:"
echo -n "##INF: PRESS ENTER TO PROCEED <ENTER>"
read d

#----- STEP 1

echo "##INF:[01/06] Installing apache"

	apt-get -y update
	apt-get -y install wget
	apt-get -y install apache2

#----- STEP 2

echo "##INF:[02/06] Installing PHP"
echo "##INF: If you plan to use PHP, it is advisable"
echo "##INF: to install now."
echo -n "##INF: Do you want to install PHP as well? "
askcs;
	if [ "$resp" = 'y' ]; then
		apt-get install php5 libapache2-mod-php5 php5-mcrypt
		#acrescentar "index.php" no apache
		##vi /etc/apache2/mods-enabled/dir.conf	
	fi

#----- STEP 3

echo -n "##INF:[03/06] Installing MONO/Mod-mono"

	#Add the last oficial repository
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
	echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | sudo tee -a /etc/apt/sources.list.d/mono-xamarin.list

	apt-get update
	apt-get -y install mono-runtime
	apt-get -y install libapache2-mod-mono
	apt-get -y install mono-apache-server2

	#Disable apache KeepAlive as recomended by mono-project for production use
	find /etc/apache2/ -name apache2.conf -type f -exec sed -i s/"KeepAlive On"/"KeepAlive Off"/g {} \;
	
	/etc/init.d/apache2 restart

#----- STEP 4

echo -n "##INF:[04/06] Configuring ASP.NET application"

echo -n " What is the name of your asp.net application?  "
read appnameInput

	#Get some templates used for replacement on config files
	wget https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/template-insert-sites.txt
	wget https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/template-insert-webapp.txt

	#Update tempalte variables	
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

#----- STEP 5

echo -n "##INF:[05/06] Execute asp.net command as root?"
echo -n "##INF: Sometimes (crazy) developers build asp.net applications"
echo -n "##INF: to execute code as a root, IE: to restart a database"
echo -n "##INF: You need special privileges configured"
echo -n "##INF: on Linux to allow this to work. "
echo -n "##INF: If you are not absolutely sure (it is not an advisable thing to do)"
echo -n "##INF: skip this step "
echo -n "##INF: Do you want to enable this? (please say skip...) "
askcs;
	if [ "$resp" = 'y' ]; then
		echo "ALL ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers"
	fi
 
 #----- STEP 5
 
echo -n "##INF:[06/06] Installing ORACLE LIBARY"
echo -n "##INF: Install you intend to use oracle with your ASP.NET"
echo -n "##INF: application."
echo -n "##INF: Do you want to install Oracle Client? "
askcs;
	if [ "$resp" = 'y' ]; then
		echo "##INF: Sorry, this step is not implemented yet "
		echo "##INF: if it is really necessary please let me know"
		echo "##INF: by sending an email to: edgarrc (at) gmail . com"
		echo "##INF: or use the issues tool: https://github.com/edgarrc/MonoUbuntu"
	fi 
 
#----- STEP 6
 
	IP=`ifconfig  | grep 'inet end.:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;	
	if [ "$IP" = "" ]; then IP="127.0.0.1"; fi
	
echo ""
echo "##INF: Installation completed!"
echo "##INF:"
echo "##INF: Publish your application to:"
echo "##INF:   /var/www/html/$appnameInput "
echo "##INF:"
echo "##INF: Application address:"
echo "##INF:"
echo "##INF:   http://$IP/$appnameInput "
echo "##INF:"
echo "##INF: Obs: If you have any error, try to restart apache again:"
echo "##INF: /etc/init.d/apache2 restart "
echo "##INF:"
echo ""
