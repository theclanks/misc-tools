#!/bin/bash

for i in `seq 3061 3120` ; do
    echo $i 
    python call.py $i & > /dev/null
done

