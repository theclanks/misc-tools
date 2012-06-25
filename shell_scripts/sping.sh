#!/bin/bash

#HOSTS="200.219.246.27 200.219.246.28 200.219.246.32 200.219.246.34 200.219.246.33 200.219.246.35 200.219.246.38 200.219.246.43 200.219.246.34 200.219.246.89"
HOSTS="186.209.79.18"
COUNT=2
TEMPO="3"

# email report when
SUB="Ping falhou - via UOL"
EMAIL="luis.carlos@virgos.com.br"
TEMP='aaa.out'
TEMP2='bbb.out'

verificaping() {

 > $TEMP
 > $TEMP2

 # fping -u $HOSTS  >> $TEMP
 #for i in ` fping -u $HOSTS`;
 #for i in ` ping -c $COUNT $HOSTS`;
  #do
  ping -c $COUNT $HOSTS
  if [ $? -ne 0 ]; then
        echo "Host : $i is down (ping failed) at $(date)" | tee -a $TEMP
        #traceroute $i | mail -s "Ping falhou - Trace Uol" $EMAIL | tee -a $TEMP2
        mtr $i --report | tee -a $TEMP2
        echo -e " \n " >> $TEMP2
    fi
# done

  falha=$(wc -l $TEMP | awk '{print$1}' )

  # Manda e-mail
  if [ $falha -ne 0 ]; then
        cat $TEMP $TEMP2 | mail -s "$SUB" $EMAIL
        cat $TEMP >> historico2.txt
        cat $TEMP2 >> traces.txt
  else echo "Link - OK"
  fi


}


while true;
 do
   verificaping
   sleep $TEMPO
   clear
done

