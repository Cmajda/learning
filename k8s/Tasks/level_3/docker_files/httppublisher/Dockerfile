FROM alpine:edge
ENV ROOT_FOLDER=usr/local/bin/httppublisher
RUN apk add --update --no-cache netcat-openbsd
RUN mkdir -p ${ROOT_FOLDER}
LABEL name="httppublisher" \
	authors="mcmajdalka@trask.cz" \
	version="1.0.4"

COPY . /${ROOT_FOLDER}/
RUN chmod a+x ./${ROOT_FOLDER}/httppublisher.sh \
	& chmod a+x ./${ROOT_FOLDER}/input_files/publish.txt

ENTRYPOINT [ "/bin/sh", "./usr/local/bin/httppublisher/httppublisher.sh" ]