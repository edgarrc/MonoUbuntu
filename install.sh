#! /bin/sh

#Collor definition
NORM="\033[0m"; AMARELO="\033[1;33m"; AZUL="\033[1;34m"; VERMELHO="\033[1;31m"; VERDE="\033[1;32m";

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
           echo -n 'Wrong anser, type again:';
           read resp;
	   continue;;
       esac
    fi
  done
}
