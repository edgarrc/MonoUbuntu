#! /bin/sh

###################################################################
#
# Script de instalação para o DeOlhoNaRede V2 em Linux Educacional 4.0 Multiterminal
#
# Obs: Erros de instalação, enviar para Edgar - edgar@valey.com.br
#
###################################################################


#variaveis
 #Definicao de cores
NORM="\033[0m"; AMARELO="\033[1;33m"; AZUL="\033[1;34m"; VERMELHO="\033[1;31m"; VERDE="\033[1;32m";
 #oracle
export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server
export ORACLE_SID=XE
export NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.UTF8'
export LD_LIBRARY_PATH=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/lib	


#Funcao de pergunta
perguntacp ()  {
  echo  -n "${VERDE} - Continuar ou Pular?${NORM} (c/p) [c]:"
  read resp

  while [ "1" = "1" ]
  do
    if [ "$resp" = '' ];
    then
      resp="y"
      break
    else
      case $resp in
        s | S | y | Y | c | C) 
           resp="y";
           break;;
        p | P ) 
		   resp="n";
	       break;;
        *)
           echo -n 'Resposta invalida, digite novamente:';
           read resp;
	   continue;;
       esac
    fi
  done
}

#Funcao de pergunta
perguntaproducao ()  {

  #Se ja tiver um web.config é porque já está instalado
  if [ -e /var/www/html/deolhonarede/Web.config ]; then
    tipoinstalacao=`cat /var/www/html/deolhonarede/Web.config | grep TIPOINSTALACAO | cut -d'"' -f4` 
  fi
  
  #Se o conteúdo do tipoinstalacao for a variavel de replace, a escolha ainda nao foi feita, pergunta, senao, usa a atual
  if [ "$tipoinstalacao" = "%TIPOINSTALACAO%" ]; then

	  echo "${AZUL}##INF:${NORM}"
	  echo "${AZUL}##INF: Existem dois modos de operacao do sistema, voce precisa escolher entre T ou P:${NORM}"
	  echo "${AZUL}##INF: (T) Teste: Esta eh uma instalacao de teste apenas, os dados registrados no sistema${NORM}"
	  echo "${AZUL}##INF:            nao sao considerados permanentes. Apenas teste de funcionamento ou treinamento.${NORM}"
	  echo "${AZUL}##INF:            Os dados serao sincronizados com o servidor de teste (homologacao) na Internet.${NORM}"
	  echo "${AZUL}##INF: (P) Producao: Esta eh uma instalacao online e final. Os dados armazenados${NORM}"
	  echo "${AZUL}##INF:            serao sincronizados com o servidor de produção Internet.${NORM}"
	  echo  -n "${VERDE} - Entre com P para producao ou T para teste:${NORM} (p/t):"
	  read respproducao

	  while [ "1" = "1" ]
	  do
		  case $respproducao in
			p | P ) 
			   respproducao="p";
			   break;;
			t | T ) 
			   respproducao="t";
			   break;;
			*)
			   echo  -n "${VERDE} Resposta invalida! Entre com P para producao ou T para teste:${NORM} (p/t):"
			   read respproducao;
		   continue;;
		   esac
	  done
  else
	wsdeolhonarede=`cat /var/www/html/deolhonarede/Web.config | grep WSDEOLHONAREDE | cut -d'"' -f4`   
    echo ""
    echo "${AZUL}##INF: Ja escolhido se homologacao ou producao: ${tipoinstalacao} ${NORM}"
  fi 
	  
}

#Funcao de pergunta inep
perguntainep ()  {
  
  #Se ja tiver um web.config é porque já está instalado
  if [ -e /var/www/html/deolhonarede/Web.config ]; then
    inepescola=`cat /var/www/html/deolhonarede/Web.config | grep INEPESCOLA | cut -d'"' -f4` 
  fi
  
  #Se o conteúdo do inepescola for a variavel de replace, pede inep, senão é porque já foi cadastrado e variavel que sera usada daqui pra frente foi carregada
  if [ "$inepescola" = "%INEPESCOLA%" ]; then
    echo ""
	while [ "1" = "1" ]
	do	  
	  echo "${AZUL}INEP - Eh *fundamental* entrar com o numero correto (sera validado), nao use o${NORM}"
	  echo "${AZUL}       numero do INEP de outra escola, isso podera causar inconsistencias nos dados${NORM}"
	  echo "${AZUL}       armazenados, como conflito de resultados de provas, por exemplo.${NORM}"
	  echo -n "${AZUL}Entre com o numero de INEP desta escola:${NORM} "
	  read inepescola
	  
	  if [ -e /tmp/saida.txt ]; then
		rm /tmp/saida.txt
	  fi
	  
	  #verifica se existe no banco local
	  /usr/bin/wget -q --tries=10 --timeout=15 http://127.0.0.1/deolhonarede/DeOlhoNaRedeWS.asmx/EscolaBO_ExisteEscolaCadastradaPorInep?inep=$inepescola -O /tmp/saida.txt
	  valido=`cat /tmp/saida.txt | grep "#" | cut -d'#' -f2`
	  
	  if [ -e /tmp/saida.txt ]; then
		rm /tmp/saida.txt
	  fi
	  
	  if [ "$valido" != 'S' ];
	  then
		echo  -n "${AZUL}Esse INEP nao foi encontrado na base local.${NORM} "
	  else
	    echo "${AZUL}INEP encontrado OK.${NORM} "
		break;		
	  fi
	  
	done
  else
    echo ""
    echo "${AZUL}##INF: Utilizando o INEP cadastrado: ${inepescola} ${NORM}"
  fi  
}

#Funcao de pergunta nome servidor
perguntaservidor ()  {
 
  #Se ja tiver um web.config é porque já está instalado
  if [ -e /var/www/html/deolhonarede/Web.config ]; then
    nomeservidor=`cat /var/www/html/deolhonarede/Web.config | grep NOMESERVIDOR | cut -d'"' -f4` 
  fi
  
  #Se o conteúdo do nomeservidor for a variavel de replace, pede o nome, senão é porque já foi cadastrado e variavel que sera usada daqui pra frente foi carregada
  if [ "$nomeservidor" = "%NOMESERVIDOR%" ]; then
    echo ""
	while [ "1" = "1" ]
	do	  
	  echo "${AZUL}Entre com o nome deste servidor. Se a escola possuir mais de uma instalacao,${NORM}"
	  echo "${AZUL}varie o nome entre os servidores da mesma escola. Escolha um nome simples e curto,${NORM}"
      echo -n "${AZUL}sem espacos (exemplos: deolhonarede01, laboratorio01, ServidorPrincipal).:${NORM}"	  
	  read nomeservidor 
	  
	  if [ "$nomeservidor" != '' ];
	  then
	    echo ""
		break;		
	  fi
	  
	done
  else
    echo ""
    echo "${AZUL}##INF: Utilizando o nome do servidor cadastrado: ${nomeservidor} ${NORM}"
  fi 
}

#se já tiver sido executado alguma instalacao, verifica se checagem enviada como parametro consta no arquivo
existecheck() {
  if [ -e "/var/log/deolhonarede_instalacao.log" ]; then
    if sudo su -c "cat /var/log/deolhonarede_instalacao.log" | grep $1 > /dev/null; then
      check="s"
    else
      check="n"
    fi
  else
    check="n"
  fi
}

##########################################################################################

#Verifica se o instalador está sendo executado dentro da pasta
if [ ! -f oracle/oracle-xe-universal_10.2.0.1-1.0_i386.deb ];
then
   echo "${AZUL}##DeOlhoNaRede: Voce precisa entrar no diretorio do instalador para executar a instalacao.${NORM}"
   echo "${AZUL}##DeOlhoNaRede: Estando dentro do diretorio, execute a instalacao com: ./instalacao.sh${NORM}"
   exit
fi

chmod +x atualiza.sh

## Remover os seguintes comentarios de linha caso esse instalador necessite a formatacao da maquina, nao faca upgrade
#if [ -e "/var/log/deolhonarede_instalacao.log" ]; then
#  echo "${AZUL}##INF: O De Olho Na Rede ja esta instalado neste computador, esta instalacao requer a formatacao.${NORM}"
#  echo "${AZUL}##INF: Obs: Nem todas as atualizações solicitarao a formatacao, algumas permitem upgrade, isso varia de acordo com os recursos atualizados e cada instalador podera solicitar ou nao a formatacao.${NORM}"
#  exit 0;
#fi

echo ""
echo "${AZUL}##INF: ----------------------------------------------${NORM}"
echo "${AZUL}##INF: Instalando DeolhoNaRede V2${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Continue apenas se este instalador estiver${NORM}"
echo "${AZUL}##INF: sendo executado como o *usuario* root${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Obs: Tenha em maos o numero do INEP valido para esta escola (nao use o numero de outra escola).${NORM}"
echo "${AZUL}##INF:   O INEP sera validado, caso nao possua, interrompa esta instalacao. (ctrl+c)${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Obs: Eh aconselhavel que este computador possua IP fixo${NORM}"
echo "${AZUL}##INF:   se for possivel, interrompa esta instalacao (ctrl+c)${NORM}"
echo "${AZUL}##INF:   configure o ip fixo do computador e execute novamente.${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Obs: Voce pode executar o instalador em modo debug.${NORM}"
echo "${AZUL}##INF:   Digite ctrl+c e inicie novamente com o comando ./instalador.sh -d${NORM}"
echo "${AZUL}##INF: ----------------------------------------------${NORM}"
echo -n "${AZUL}##INF: PARA PROSSEGUIR PRESSIONE <ENTER>${NORM}"
read d

apt-get -y install unzip

#inicio das etapas

existecheck "VARIAVEIS_CHECK";
echo -n "${AZUL}##INF:[01/16] Configurando variaveis de ambiente${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		echo "LD_LIBRARY_PATH=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/lib" >> /etc/enviroment
		echo "NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.UTF8'" >> /etc/enviroment
		echo "ORACLE_SID=XE" >> /etc/enviroment
		echo "ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server" >> /etc/enviroment
		
		echo "export LD_LIBRARY_PATH=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/lib" >> /etc/bash.bashrc
		echo "export NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.UTF8'" >> /etc/bash.bashrc
		echo "export ORACLE_SID=XE" >> /etc/bash.bashrc
		echo "export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server" >> /etc/bash.bashrc
		
		#Registra que esta etapa já foi executada neste computador
		echo "VARIAVEIS_CHECK" >> /var/log/deolhonarede_instalacao.log	
	fi
fi


existecheck "LIBAIO_CHECK";
echo -n "${AZUL}##INF:[02/16] Instalando dependências do Oracle${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		dpkg -i oracle/libaio_0.3.104-1_i386.deb
		
		#Registra que esta etapa já foi executada neste computador
		echo "LIBAIO_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi


existecheck "ORACLE_PKG_CHECK";	
echo -n "${AZUL}##INF:[03/16] Instalando o oracle${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		dpkg -i oracle/oracle-xe-universal_10.2.0.1-1.0_i386.deb
		
		#Registra que esta etapa já foi executada neste computador
		echo "ORACLE_PKG_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi


existecheck "ORACLE_CONFIG_RUN_CHECK";
echo -n "${AZUL}##INF:[04/16] Configurando o Oracle${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		cp oracle/oracle-xe /etc/init.d/oracle-xe
		chmod +x /etc/init.d/oracle-xe
		/etc/init.d/oracle-xe configure
		
		/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/sqlplus sys/123@xe as sysdba @deolhonarede/corrigebanco.sql
		
		#Registra que esta etapa já foi executada neste computador
		echo "ORACLE_CONFIG_RUN_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi	


existecheck "USUARIO_CHECK";
echo -n "${AZUL}##INF:[05/16] Criando usuario deolhonarede${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/sqlplus system/123@xe @deolhonarede/criauser.sql
		
		#Registra que esta etapa já foi executada neste computador
		echo "USUARIO_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi


existecheck "IMP_DUMP_CHECK";
echo -n "${AZUL}##INF:[06/16] Importando dump deolhonarede${NORM}"
if [ $check  = "s" ]; then
  echo -n "${AZUL}\n##INF:  Este computador ja possui um banco de dados instalado, se atualizar, todas as informacoes locais serao perdidas. Deseja atualiza-lo?${NORM}"
  perguntacp;
  if [ "$resp" = 'y' ];
  then
    /etc/init.d/oracle-xe restart
    /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/sqlplus system/123@xe @deolhonarede/recriauser.sql
	
	echo "${AZUL}\n##INF:Descompactando banco...${NORM}"
	cd deolhonarede
	unrar e -pdeolhop1 deolho_producaoUPDATE.rar
	mv exp-atte-*.dmp atteUPDATE.dmp
	cd ..
	
    /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/imp deolhonarede/123@xe FILE=deolhonarede/atteUPDATE.dmp full=yes
	#Acabou de importar, então marca todos os registros como sem necessidade de sincronismo
	echo "${AZUL}\n##INF:Executando update, esta etapa pode demorar varios minutos...${NORM}"
	/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/sqlplus deolhonarede/123@xe @deolhonarede/updaterkey.sql

	rm deolhonarede/atteUPDATE.dmp
	
  fi  
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
	
		echo "${AZUL}\n##INF:Descompactando banco...${NORM}"
		cd deolhonarede
		unrar e -pdeolhop1 deolho_producaoUPDATE.rar
		mv exp-atte-*.dmp atteUPDATE.dmp
		cd ..	
	
		/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/imp deolhonarede/123@xe FILE=deolhonarede/atteUPDATE.dmp full=yes
		#Acabou de importar, então marca todos os registros como sem necessidade de sincronismo
		echo "${AZUL}\n##INF:Executando update, esta etapa pode demorar varios minutos...${NORM}"
		/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/bin/sqlplus deolhonarede/123@xe @deolhonarede/updaterkey.sql
		
		rm deolhonarede/atteUPDATE.dmp
		
		#Registra que esta etapa já foi executada neste computador
		echo "IMP_DUMP_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi


existecheck "APP_E_PERMISSOES_CHECK";
echo -n "${AZUL}##INF:[07/16] Instalando aplicacao e aplicando permissoes${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Este computador ja possui a aplicacao e servico instalados, apenas atualizando...${NORM}"

  #captura as variaveis de inep e nome do servidor que estao no web.config. Como já houve instalação, nada sera perguntado
  perguntainep;
  perguntaservidor;
  perguntaproducao;
  
  rm -rf /var/www/html/deolhonarede  
  mkdir -p /var/www/html/deolhonarede
  unzip deolhonarede/deolhonaredeUPDATE.zip -d /var/www/html/deolhonarede
  chown -R www-data:www-data /var/www
 
  rm -rf /DeOlhoNaRede/DeolhonaredeService
  mkdir -p /DeOlhoNaRede/DeolhonaredeService
  unzip deolhonarede/DeolhonaredeServiceUPDATE.zip -d /DeOlhoNaRede/DeolhonaredeService
  
  #cp deolhonarede/DeolhonaredeServiceVerify.sh /DeOlhoNaRede/DeolhonaredeServiceVerify.sh
  #chmod +x /DeOlhoNaRede/DeolhonaredeServiceVerify.sh

  chown -R www-data:www-data /DeOlhoNaRede   
  
  #Substitui variaveis no web.config
  find /var/www/html -name Web.config -type f -exec sed -i s/"%INEPESCOLA%"/"$inepescola"/g {} \;
  find /var/www/html -name Web.config -type f -exec sed -i s/"%NOMESERVIDOR%"/"$nomeservidor"/g {} \;    
  find /var/www/html -name Web.config -type f -exec sed -i s#"%WSDEOLHONAREDE%"#"$wsdeolhonarede"#g {} \;
  find /var/www/html -name Web.config -type f -exec sed -i s/"%TIPOINSTALACAO%"/"$tipoinstalacao"/g {} \;  
  
  /etc/init.d/apache2 restart
  
else

	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		mkdir -p /var/www/html/deolhonarede
		unzip deolhonarede/deolhonaredeUPDATE.zip -d /var/www/html/deolhonarede
		chown -R www-data:www-data /var/www

		#Estrutura de logs, arquivos temporários etc
		mkdir /DeOlhoNaRede
		
		#Instala o servico
		mkdir -p /DeOlhoNaRede/DeolhonaredeService
		unzip deolhonarede/DeolhonaredeServiceUPDATE.zip -d /DeOlhoNaRede/DeolhonaredeService
		
		#Instala o verificador do servico
        #cp deolhonarede/DeolhonaredeServiceVerify.sh /DeOlhoNaRede/DeolhonaredeServiceVerify.sh
		#chmod +x /DeOlhoNaRede/DeolhonaredeServiceVerify.sh		

		chown -R www-data:www-data /DeOlhoNaRede  		
	
		#acrescentado para que o apache possa executar comandos no shell como root, entre eles, reiniciar bd
		echo "ALL ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers"
		
		#Como não é a primeira instalação (não é atualização) a substituição de variáveis
		#ficou em etapas seguintes. O sistema precisa estar inteiramente instalado para validar o inep

		#Registra que esta etapa já foi executada neste computador
		echo "APP_E_PERMISSOES_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
	
fi


existecheck "MONO_RUNTIME_CHECK";
echo -n "${AZUL}##INF:[08/16] Instalando Runtime do mono${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		
		sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/edgarrc/MonoUbuntu/master/installSilent.sh)$"		
		
		#Registra que esta etapa já foi executada neste computador
		echo "MONO_RUNTIME_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi


existecheck "CONF_APACHE_MONO_TNS_CHECK";
echo -n "${AZUL}##INF:[12/16] Configurando apache, mono, oracle${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
		cp conf/tnsnames.ora /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin
		##cp conf/default /etc/apache2/sites-available
		##cp conf/default.webapp  /etc/mono-server2
		##cp conf/default.webapp  /etc/mono-server4
		###apenas remove keep alive e seta o ServerRoot
		##cp conf/apache2.conf /etc/apache2
		
		echo "export NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.UTF8'" >> /etc/apache2/envvars
		echo "export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server/" >> /etc/apache2/envvars
		echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib" >> /etc/apache2/envvars	
		
		##cp conf/envvars /etc/apache2/envvars
		
		/etc/init.d/apache2 restart
		
		#Registra que esta etapa já foi executada neste computador
		echo "CONF_APACHE_MONO_TNS_CHECK" >> /var/log/deolhonarede_instalacao.log
	fi
fi	


echo -n "${AZUL}##INF:[13/16] Verificando cadastro de INEP e nome do servidor${NORM}"
#pergunta pelo inep e nome do servidor (se for o caso, ver código de cada um), já preenche variaveis globais a serem utilizadas a seguir
perguntainep;
perguntaservidor;
#Substitui variaveis no web.config
find /var/www/html -name Web.config -type f -exec sed -i s/"%INEPESCOLA%"/"$inepescola"/g {} \;
find /var/www/html -name Web.config -type f -exec sed -i s/"%NOMESERVIDOR%"/"$nomeservidor"/g {} \;


existecheck "SERVICODEOLHO_CHECK";
echo -n "${AZUL}##INF:[14/16] Configurando servico${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
fi
if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
if [ "$resp" = 'y' ];
then

	#Remove o auto update do crontab
	echo "" | crontab

	#agenda o script que mantem o servico online
	 #bkp do atual
	 #(linha seguinte comentada, nao faz backup do atual, o LE4 vem com update agendado automaticamente, dessa forma já retira)
	#crontab -l > /tmp/crontab.b
	
	#echo "* * * * * su - root -c /DeOlhoNaRede/DeolhonaredeServiceVerify.sh >> /dev/null"  >> /tmp/crontab.b
	#cat /tmp/crontab.b | crontab
	#rm /tmp/crontab.b

	cp deolhonarede/DeolhonaredeInit /etc/init.d
	chmod +x /etc/init.d/DeolhonaredeInit
	echo "/etc/init.d/DeolhonaredeInit start" > /etc/rc.local
	
	#Ajusta a url do serviço de sincronismo (ele le do Web.config do appweb) de acordo com o tipo produção ou homologacao
	perguntaproducao;
	if [ "$respproducao" = "p" ];
	then
		find /var/www/html -name Web.config -type f -exec sed -i s#"%WSDEOLHONAREDE%"#"http://www.deolhonarede.atte.com.br/DeOlhoNaRedeWS.asmx"#g {} \;
		find /var/www/html -name Web.config -type f -exec sed -i s/"%TIPOINSTALACAO%"/"producao"/g {} \;
		mkdir -p /DeOlhoNaRede/producao
	else
		find /var/www/html -name Web.config -type f -exec sed -i s#"%WSDEOLHONAREDE%"#"http://homologacao.deolhonarede.atte.com.br/deolhonarede/DeOlhoNaRedeWS.asmx"#g {} \;
		find /var/www/html -name Web.config -type f -exec sed -i s/"%TIPOINSTALACAO%"/"homologacao"/g {} \;
		mkdir -p /DeOlhoNaRede/homologacao
	fi
	
	chown -R www-data:www-data /DeOlhoNaRede
		
	#Registra que esta etapa já foi executada neste computador independente de ser p ou t, para não perguntar novamente
	echo "SERVICODEOLHO_CHECK" >> /var/log/deolhonarede_instalacao.log
fi


existecheck "BACKUP_CHECK";
echo -n "${AZUL}##INF:[16/16] Configurando backup, agendando e realizando primeiro backup${NORM}"
if [ $check  = "s" ]; then
  echo "${AZUL}\n##INF:  Esta etapa ja foi executada neste computador, pulando...${NORM}"
else
	if [ "$1" = "-d" ]; then perguntacp ; else resp="y"; echo ""; fi
	if [ "$resp" = 'y' ];
	then
	
		#habilitando arquivelog
		chmod +x deolhonarede/archivelog.sh
		cp deolhonarede/archivelog.sql /usr/lib/oracle/xe
		cp deolhonarede/archivelog.sh /usr/lib/oracle/xe
		su - oracle -c "./archivelog.sh"
		
		#script de backup
		cp oracle/backup.sh /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/scripts/backup.sh
		
		#Executa primeiro
		su - oracle -c /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/scripts/backup.sh

		#Agendando
		echo "0 */2 * * * su - oracle -c /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/config/scripts/backup.sh >> /dev/null"  >> /tmp/crontab.b
		cat /tmp/crontab.b | crontab
		rm /tmp/crontab.b
		
		#Registra que esta etapa já foi executada neste computador
		echo "BACKUP_CHECK" >> /var/log/deolhonarede_instalacao.log		
	fi
fi

/etc/init.d/DeolhonaredeInit stop
/etc/init.d/DeolhonaredeInit start
/etc/init.d/apache2 restart


#obtem o end ip
IP=`ifconfig  | grep 'inet end.:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;	
if [ "$IP" = "" ]; then IP="127.0.0.1"; fi

echo ""
echo "${AZUL}##INF: Instalacao concluida!${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Endereco da aplicacao:${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: ${AMARELO}http://$IP/deolhonarede ${NORM}"
echo "${AZUL}##INF:${NORM}"
echo "${AZUL}##INF: Obs: Caso o sistema apresente algum erro, digite o seguinte comando e tente novamente:${NORM}"
echo "${AZUL}##INF: ${AMARELO}/etc/init.d/apache2 restart ${NORM}"
echo "${AZUL}##INF:${NORM}"
echo ""

