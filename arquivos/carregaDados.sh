#!/bin/sh

echo "Verificando variáveis de sistema: "
echo "   HOSTNAMELINK: "$HOSTNAMELINK
echo "   DBNAME: "$DBNAME
echo "   DBUSERNAME: "$DBUSERNAME
echo "   DBPASSWORD: "$DBPASSWORD

PORT=5432
export PGPASSWORD=$DBPASSWORD
echo ""
echo "Carregando dados da aplicação ..."

echo "      ...executando o script SQL para CARGA DO DOMÍNIO DE DADOS..."
psql -qh $HOSTNAMELINK -p $PORT -U $DBUSERNAME $DBNAME -f /opt/GOG/GOG/src/main/resources/ScriptCargaDominio.sql

echo "      ...executando o script SQL para CARGA DE DADOS COMPLEMENTARES..." 
psql -qh $HOSTNAMELINK -p $PORT -U $DBUSERNAME $DBNAME -f /opt/ScriptCargaComplementar.sql

echo "      ...executando o script SQL para CRIAÇÃO DA VIEW DE ESTATÍSTICAS DE MANIFESTAÇÃO"
psql -qh $HOSTNAMELINK -p $PORT -U $DBUSERNAME $DBNAME -f /opt/GOG/GOG/src/main/resources/CREATE\ VwEstatisticasManifestacao.sql

echo "      ...executando o script SQL para CRIAÇÃO DA VIEW DE ÚLTIMO TRAMITE"
psql -qh $HOSTNAMELINK -p $PORT -U $DBUSERNAME $DBNAME -f /opt/GOG/GOG/src/main/resources/CREATE\ vwUltimoTramite.sql




 
