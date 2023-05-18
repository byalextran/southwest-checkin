#!/bin/sh

#start ATD
service atd start

## Initial starup getting sw headers
echo "---- Creating Southwest Headers ----"
cd /home/swcheckin/southwest-headers && \
python3 southwest-headers.py /home/swcheckin/data/southwest_headers.json
echo "---- Creation Finished ----"

## Setup gem
cd /home/swcheckin/southwest-checkin && \
gem install autoluv

## Now loop the header updates
while true
do  
    sleep 1d
    echo "---- Updating Southwest Headers ----"
    cd /home/swcheckin/southwest-headers && \
    python3 southwest-headers.py /home/swcheckin/data/southwest_headers.json
    echo "---- Updating Finished.  Waiting 24 hours ----"
done
