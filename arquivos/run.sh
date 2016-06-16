#!/bin/bash

if [ "$JBOSS_PASS" = "**Random**" ]; then
    unset JBOSS_PASS
fi

if [ ! -f /.jboss_admin_pass_configured ]; then
    /opt/set_jboss_admin_pass.sh
fi

echo "Vai configurar o nome do HOST de banco de dados"
HOSTNAME="10.0.0.217"
# Verifica o valor da variável de ambiente
if [ -n "$HOSTNAMELINK" ]; then
    HOSTNAME=$HOSTNAMELINK
fi

echo "Verificando variáveis de sistema: "
echo "   HOSTNAME: "$HOSTNAME
echo "   DBNAME: "$DBNAME
echo "   DBUSERNAME: "$DBUSERNAME
echo "   DBPASSWORD: "$DBPASSWORD
echo "   DBSCHEMA: "$DBSCHEMA

sed -i -r "s/HOSTNAME/$HOSTNAME/" /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -r "s/DBNAME/$DBNAME/" /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -r "s/DBUSERNAME/$DBUSERNAME/" /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -r "s/DBPASSWORD/$DBPASSWORD/" /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -r "s/DBSCHEMA/$DBSCHEMA/" /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml


# Aguardar a configuração do serviço de bancos para iniciar o jboss...
echo "Vai esperar o serviço de Banco de Dados ser configurado ..."
PORT=5432
export PGPASSWORD=$DBPASSWORD
while true; do
   if psql -lqt -h $HOSTNAME -p $PORT -U $DBUSERNAME $DBNAME | cut -d \| -f 1 | grep -qw $DBNAME; then
       echo "...Banco de Dados pronto"
       break
   else
       echo "...O BD ainda não foi configurado"
       sleep 5
   fi
done


echo "Vai iniciar o Jboss ..."
/opt/jboss-as-7.1.1.Final/bin/standalone.sh -b=0.0.0.0 &
# Aguardar o jboss subir...
sleep 5

echo "Vai realizar o deploy ..."
/opt/jboss-as-7.1.1.Final/bin/jboss-cli.sh --connect --command="deploy /opt/GOG/GOG/target/GOG.war --force"
echo "Jboss iniciado com o depĺoy realizado"

echo "...Agora vamos carregar os dados do sistema..."
sh /opt/carregaDados.sh 

echo -e "\n\n\nPRONTO! O GOG está funcionando! Use: http://localhost:8080/GOG"

while :
do
	sleep 1
done
