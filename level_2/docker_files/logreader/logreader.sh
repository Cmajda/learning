#!/bin/sh
ROOT_FOLDER="`dirname \"$0\"`"

while :
do
cat ./$ROOT_FOLDER/logs/* 1> /dev/null | shuf -n 1
cat ./$ROOT_FOLDER/logs/* 2> /dev/null | shuf -n 1 

sleep 2

done