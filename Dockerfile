FROM alpine

RUN apk add --update gcc flex bison make libc-dev flex-dev

WORKDIR /prac1

VOLUME /prac1

CMD ["/bin/sh"]