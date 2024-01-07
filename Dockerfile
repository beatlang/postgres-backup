FROM postgres:16-alpine

RUN apk update

# Install azure cli
RUN apk add py3-pip
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make
RUN apk add --update py3-pip

RUN py3-pip install azure-cli

COPY backup.sh .

ENTRYPOINT [ "/bin/sh" ]
CMD [ "./backup.sh" ]