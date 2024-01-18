FROM adoptopenjdk/openjdk11:jre-11.0.19_7-ubuntu

ARG RELEASE=2.22.1
ARG ALLURE_REPO=https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline
ARG USER=appuser
ENV ROOT=/home/$USER/app \
    PATH=$PATH:/allure-$RELEASE/bin \
    HOME="/home/${USER}"

RUN echo $RELEASE && \
    apt-get update && \
    apt-get install -y bash wget unzip sudo --no-install-recommends && \
    wget --no-verbose -O /tmp/allure-$RELEASE.tgz $ALLURE_REPO/$RELEASE/allure-commandline-$RELEASE.tgz && \
    tar -xf /tmp/allure-$RELEASE.tgz && \
    rm -rf /tmp/* && \
    chmod -R +x /allure-$RELEASE/bin && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p $ROOT

COPY ./entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]

# Configure non-root user
RUN adduser --disabled-password --gecos "" "$USER"  && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 0440 "/etc/sudoers.d/${USER}"
USER ${USER}
WORKDIR "/home/${USER}/app"
