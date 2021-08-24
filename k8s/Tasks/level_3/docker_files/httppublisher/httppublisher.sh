#!/bin/sh
ROOT_FOLDER="`dirname \"$0\"`"

while :
do { echo -e 'HTTP/1.1 200 OK\r\n'; shuf -n 1 ./$ROOT_FOLDER/input_files/publish.txt; } | nc -l 8181
done