FROM alpine:edge
ENV ROOT_FOLDER=usr/local/bin/httpreader
RUN apk add --update --no-cache netcat-openbsd
RUN	apk add --update --no-cache curl
RUN mkdir -p ${ROOT_FOLDER}

LABEL name="httpreader" \
	authors="mcmajdalka@trask.cz" \
	version="1.0.2"

COPY . /${ROOT_FOLDER}/
RUN chmod a+x ./${ROOT_FOLDER}/httpreader.sh

ENTRYPOINT [ "/bin/sh", "./usr/local/bin/httpreader/httpreader.sh" ]