#!/bin/bash

set -e # stop the script on errors
set -o pipefail # piping a failed process into a successful one is an error

rsync --exclude='.git/' --exclude='nm*.csv.gz' -az --compress-level=9 --stats -e 'ssh -i /root/.ssh/XXX' --delete /root/new.XXX  XXX@"$IPADDRESS":/home/XXX
# copy the csv.gz files to data.diegovalle.net
rsync --omit-dir-times -rz --compress-level=9 --stats -e 'ssh -i /root/.ssh/XXX' /root/new.XXX/report-crime/data/  XXX@"$IPADDRESS":/var/www/data.diegovalle.net/elcrimen


DATE=$(date +%Y-%m-%d-%H-%Z)
LATEST_RELEASE=/var/www/report-crime/$DATE
CURRENT_PATH=/var/www/report-crime/public
CURRENT_PATH_TMP=/var/www/report-crime/$DATE.tmp
ssh -i /root/.ssh/XXX XXX@"$IPADDRESS" "mkdir -p $LATEST_RELEASE && cp -r /home/XXX/new.XXX/report-crime/* $LATEST_RELEASE && ln -s $LATEST_RELEASE $CURRENT_PATH_TMP && mv -T $CURRENT_PATH_TMP $CURRENT_PATH"



# remove the crime csv files since we already copied them to
# data.diegovalle.net and don't want them cluttering the netlify website
rm -f ~/new.XXX/report-crime/data/*.csv.gz
cd ~/new.XXX/report-crime && netlify deploy --auth="$NETLIFYAPIKEY" --site=b399b452-d320-4949-8c4d-f32ea339db82 --dir=. --prod && cd ..
