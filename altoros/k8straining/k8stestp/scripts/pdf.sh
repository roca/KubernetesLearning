#!/bin/bash
set -e
# This script exports all the slidedecks to the offline format

SERVER=http://localhost:9000
PREFIX="andyfiorini/k8stestp/master?grs=github&t=white&fragments=false"
DECKTAPE=decktape

mkdir -p pdf

# for DAY in "day1" "day2" "day3"
for DAY in "day1"
do
echo $DAY
mkdir -p pdf/$DAY

for SLIDE in $DAY/??-*
  do
    echo "Export $SLIDE"
    $DECKTAPE $SERVER/$PREFIX\&p=$SLIDE pdf/$SLIDE.pdf
  done
done
