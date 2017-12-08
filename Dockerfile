FROM alpine

RUN apk add --update gcc flex bison make libc-dev flex-dev python3

WORKDIR /prac

VOLUME /prac

CMD ["/bin/sh"]