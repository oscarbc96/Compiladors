FROM alpine

RUN apk add --update gcc flex bison make libc-dev flex-dev

WORKDIR /prac

VOLUME /prac

CMD ["/bin/sh"]