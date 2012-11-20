#!/bin/bash

> lista_audio_ok

ls *.gsm > lista_audio

#for i in `ls *.gsm`; do
for i in `cat lista_audio`; do

  DURACAO=$(nohup sox $i -e stat | grep Length | awk '{print$3}');
  TOTAL=$(echo "scale=3 ; $DURACAO / 2" | bc);

  DURACAOD=$(echo $DURACAO | awk '{printf("%d\n", $1 * 1)}')

  ARQUIVO=$(basename $i .gsm)

  #echo $DURACAOD

  if [ $DURACAOD -gt 2 ]; then
    sox $i $ARQUIVO"-in.gsm" trim 0 $TOTAL
    sox $i $ARQUIVO"-out.gsm" trim $TOTAL $DURACAO
    soxmix $ARQUIVO"-in.gsm" $ARQUIVO"-out.gsm" final/$ARQUIVO".gsm"

    echo $i >> lista_audio_ok
    echo $i - $DURACAO $TOTAL
    rm $ARQUIVO"-in.gsm" $ARQUIVO"-out.gsm"
  else
    echo $i >> lista_audio_ok
    echo "$i - Arquivo muito pequeno"
  fi

done


