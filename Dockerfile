FROM mcr.microsoft.com/azure-cli:latest

RUN apk update
RUN apk add postgresql-client

COPY backup.sh .

ENTRYPOINT [ "/bin/sh" ]
CMD [ "./backup.sh" ]