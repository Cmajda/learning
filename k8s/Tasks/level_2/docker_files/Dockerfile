FROM alpine:edge
LABEL name="logreader" \
    authors="mcmajdalka@trask.cz" \
    version="1.0.0"
ENV ROOT_FOLDER=usr/local/bin
RUN adduser -D lsf 
COPY . /${ROOT_FOLDER}/
RUN chmod a+x ./${ROOT_FOLDER}/logreader/logreader.sh
USER lsf
ENTRYPOINT [ "/bin/sh", "./usr/local/bin/logreader/logreader.sh" ]
#ENTRYPOINT [ "/bin/sh", "./${ROOT_FOLDER}/logreader/logreader.sh" ]
