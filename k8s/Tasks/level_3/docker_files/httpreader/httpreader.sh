#!/bin/sh
while true
do (
	curl -l http://localhost:8181
	curl -l http://svc-cl-httppublisher:8181
	)
sleep 1
done