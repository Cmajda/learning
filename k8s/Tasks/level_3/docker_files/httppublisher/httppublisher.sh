#!/bin/sh
ROOT_FOLDER="`dirname \"$0\"`"
r="`shuf -n 1 ./$ROOT_FOLDER/input_files/publish.txt`"
while true
do (
	r="`shuf -n 1 ./$ROOT_FOLDER/input_files/publish.txt`"
	echo -e 'HTTP/1.1 200 OK\r\n'
	echo -e "\r\n<H1>Learning k8s</H1>\r\n <H2>$r</H2>"
	) | timeout 1  nc -lp 8181
done