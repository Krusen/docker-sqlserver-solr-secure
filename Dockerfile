FROM nginx:mainline-alpine

ARG SERVER_NAME=solr

ENV SSL_CERTIFICATE=/etc/ssl/certs/snakeoil.cer
ENV SSL_CERTIFICATE_KEY=/etc/ssl/private/snakeoil.key
RUN apk add --no-cache openssl \
    && openssl ecparam -out ${SSL_CERTIFICATE_KEY} -name prime256v1 -genkey \
    && openssl req -new -key ${SSL_CERTIFICATE_KEY} -x509 -sha256 -nodes \
        -days 3650 -subj "/CN=${SERVER_NAME}" -out ${SSL_CERTIFICATE}

RUN rm /etc/nginx/conf.d/*.conf

COPY . /

ENTRYPOINT ["/docker-entrypoint.sh"]