FROM alpine

RUN apk add --update gcc flex bison make libc-dev flex-dev

WORKDIR /prac2

VOLUME /prac2

CMD ["/bin/sh"]