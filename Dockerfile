FROM openjdk:8-jre-alpine

ARG RELEASE=2.18.1
ARG ALLURE_REPO=https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline
ARG USER=appuser
ENV ROOT=/home/$USER/app \
    PATH=$PATH:/allure-$RELEASE/bin \
    HOME="/home/${USER}"

RUN echo $RELEASE && \
    apk update && \
    apk add --no-cache bash wget unzip && \
    wget --no-verbose -O /tmp/allure-$RELEASE.tgz $ALLURE_REPO/$RELEASE/allure-commandline-$RELEASE.tgz && \
    tar -xf /tmp/allure-$RELEASE.tgz && \
    rm -rf /tmp/* && \
    chmod -R +x /allure-$RELEASE/bin && \
    rm -rf /var/cache/apk/*

RUN mkdir -p $ROOT

COPY ./entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]

# Configure non-root user
RUN apk add --update sudo && \
    adduser -D "$USER" && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 0440 "/etc/sudoers.d/${USER}"
USER ${USER}
WORKDIR "/home/${USER}/app"
