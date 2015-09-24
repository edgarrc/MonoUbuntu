#! /bin/sh
######################################################
# This script is provided as is, use at your own risk
#
# For more information about issues, make suggestions, changes
# bugs etc, please refer to: https://github.com/edgarrc/MonoUbuntu
#
# Edgar
######################################################

#Collor definition
NORM="\033[0m"; AMARELO="\033[1;33m"; AZUL="\033[1;34m"; VERMELHO="\033[1;31m"; VERDE="\033[1;32m";

#Helper function to ask for continue or skipt
askcs ()  {
  echo  -n "${VERDE} - Continue or skip?${NORM} (c/s) [c]:"
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
echo "${AZUL}##INF: ----------------------------------------------${NORM}"
echo "${AZUL}##INF: Mono/apache - Ubuntu install${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Do not continue if mono or apache is already installed${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Execute with sudo${NORM}"
echo "${AZUL}##INF: if you are not executing with sudo exit now (ctrl+c)${NORM}"
echo "${AZUL}##INF: and type${NORM}"
echo "${AZUL}##INF:   ./sudo install.sh${NORM}"
echo "${AZUL}##INF:${NORM}"
echo -n "${AZUL}##INF: PRESS ENTER TO PROCEED <ENTER>${NORM}"
read d

#----- STEP 1

echo -n "${AZUL}##INF:[01/06] Installing apache${NORM}"

	apt-get update
	apt-get install wget
	apt-get install apache2

#----- STEP 2

echo -n "${AZUL}##INF:[02/06] Installing PHP${NORM}"
echo -n "${AZUL}##INF: If you plan to use PHP, it is advisable${NORM}"
echo -n "${AZUL}##INF: to install now.${NORM}"
echo -n "${AZUL}##INF: Do you want to install PHP as well? ${NORM}"
askcs;
	if [ "$resp" = 'y' ]; then
		apt-get install php5 libapache2-mod-php5 php5-mcrypt
		#acrescentar "index.php" no apache
		##vi /etc/apache2/mods-enabled/dir.conf	
	fi

#----- STEP 3

echo -n "${AZUL}##INF:[03/06] Installing MONO/Mod-mono${NORM}"

	#Add the last oficial repository
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
	echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | sudo tee -a /etc/apt/sources.list.d/mono-xamarin.list

	apt-get update
	apt-get install mono-runtime
	apt-get install libapache2-mod-mono
	apt-get install mono-apache-server2

	#Disable apache KeepAlive as recomended by mono-project for production use
	find /etc/apache2/ -name apache2.conf -type f -exec sed -i s/"KeepAlive On"/"KeepAlive Off"/g {} \;

#----- STEP 4

echo -n "${AZUL}##INF:[04/06] Configuring asp.net application${NORM}"

echo -n "${AZUL} What is the name of your asp.net application? ${NORM} "
read appnameInput

	#Get some templates used for replacement on config files
	wget https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/template-insert-sites.txt
	wget https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/template-insert-webapp.txt

	#Update tempalte variables	
	find ./ -name template-insert-sites.txt -type f -exec sed -i s/"%APPNAME%"/"$appnameInput"/g {} \;
	find ./ -name template-insert-webapp.txt -type f -exec sed -i s/"%APPNAME%"/"$appnameInput"/g {} \;
	
	#Apply to apache default website configuration
	sed -i '/<VirtualHost *:80>/r template-insert-sites.txt' /etc/apache2/sites-enabled/000-default.conf	

	#Apply to default.webapp	
	sed -i '/<apps>/r template-insert-webapp.txt' /etc/mono-server4/default.webapp
	
	#Remove templates
	rm template-insert-sites.txt
	rm template-insert-webapp.txt 
	 
	#Create directory for application
	mkdir -p /var/www/html/$appnameInput
	chown -R www-data:www-data /var/www

#----- STEP 5

echo -n "${AZUL}##INF:[05/06] Execute asp.net command as root?${NORM}"
echo -n "${AZUL}##INF: Sometimes (crazy) developers build asp.net applications${NORM}"
echo -n "${AZUL}##INF: to execute code as a root, IE: to restart a database${NORM}"
echo -n "${AZUL}##INF: You need special privileges configured${NORM}"
echo -n "${AZUL}##INF: on Linux to allow this to work. ${NORM}"
echo -n "${AZUL}##INF: If you are not absolutely sure (it is not an advisable thing to do)${NORM}"
echo -n "${AZUL}##INF: skip this step ${NORM}"
echo -n "${AZUL}##INF: Do you want to enable this? (please say skip...) ${NORM}"
askcs;
	if [ "$resp" = 'y' ]; then
		echo "ALL ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers"
	fi
 
 #----- STEP 5
 
echo -n "${AZUL}##INF:[06/06] Installing ORACLE LIBARY${NORM}"
echo -n "${AZUL}##INF: Install you intend to use oracle with your ASP.NET${NORM}"
echo -n "${AZUL}##INF: application.${NORM}"
echo -n "${AZUL}##INF: Do you want to install Oracle Client? ${NORM}"
askcs;
	if [ "$resp" = 'y' ]; then
		echo "${AZUL}##INF: Sorry, this step is not implemented yet ${NORM}"
		echo "${AZUL}##INF: if it is really necessary please let me know"
		echo "${AZUL}##INF: by sending an email to: edgarrc (at) gmail . com"
		echo "${AZUL}##INF: or use the issues tool: https://github.com/edgarrc/MonoUbuntu"
	fi 
 
#----- STEP 6
 
	IP=`ifconfig  | grep 'inet end.:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;	
	if [ "$IP" = "" ]; then IP="127.0.0.1"; fi

echo ""
echo "${AZUL}##INF: Installation completed!${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Publish your application to:${NORM}"
echo "${AZUL}##INF: ${AMARELO}/var/www/html/$appnameInput ${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Application address:${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: ${AMARELO}http://$IP/$appnameInput ${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Obs: If you have any error, try to restart apache again:${NORM}"
echo "${AZUL}##INF: ${AMARELO}/etc/init.d/apache2 restart ${NORM}"
echo "${AZUL}##INF:${NORM}"
echo ""
 
