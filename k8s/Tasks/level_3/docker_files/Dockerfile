FROM alpine:edge
RUN apk add --update --no-cache netcat-openbsd
LABEL name="httppublisher" \
    authors="mcmajdalka@trask.cz" \
    version="1.0.0"
ENV ROOT_FOLDER=usr/local/bin
COPY . /${ROOT_FOLDER}/
RUN chmod a+x ./${ROOT_FOLDER}/httppublisher/httppublisher.sh \
& chmod a+x ./${ROOT_FOLDER}/httppublisher/input_files/publish.txt

ENTRYPOINT [ "/bin/sh", "./usr/local/bin/httppublisher/httppublisher.sh" ]

