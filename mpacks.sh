#!/bin/bash
# Monitora pacotes

# Configuracoes
email="luis.carlos@virgos.com.br"
tempo="30"
host="200.219.246.49"

# local para arquivos temporarios
apath="/tmp"

# arquivos temporarios
a0="$apath/monpack.txt"
a4="$apath/monpack_alerta.txt"

> $a0


GeraLista() {
  mtr $host --curses --report | awk 'NR > 1 {print $1,$2}' | grep -v " 0.0%" | grep -v " 0%" >> $a0
}

EnviaAlerta() {
> $a4
       echo -e "`date` - Perda de Pacotes em $host: \n " | tee -a $a4
       cat $a0 | awk 'NR > '$contador' {print $0}'| tee -a $a4
       mail -s "MonPack" $email < $a4
}

contador=0;

       while true;
        do

               GeraLista;

               linhas=$(cat $a0 | wc -l | awk '{print$1}')

               if [ $linhas -gt $contador ]; then
                 EnviaAlerta;
                 contador=$linhas;
               fi
               sleep $tempo;
       done;

