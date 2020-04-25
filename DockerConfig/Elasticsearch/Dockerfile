FROM docker.elastic.co/elasticsearch/elasticsearch:7.6.2
ARG UID
ARG GID
USER root

RUN groupmod -g $UID elasticsearch && \
    usermod -u $GID elasticsearch && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
USER elasticsearch
