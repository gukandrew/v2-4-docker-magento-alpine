FROM node:14-alpine3.10
WORKDIR /var/www

RUN apk add yarn sudo openssl git && \
    apk add curl && \
    rm -f /var/cache/apk/*

# CMD yarn build && yarn start
CMD yarn watch

# CMD tail -f /dev/null

EXPOSE 80 443
