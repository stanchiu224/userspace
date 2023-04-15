FROM alpine:latest
MAINTAINER Stanley Chiu 
LABEL maintainer "Stanley Chiu  <stanchiu224@gmail.com>>"
LABEL org.opencontainers.image.source https://github.com/stanchiu224/userspace 


ARG user=stanchiu224
ARG group=wheel
ARG uid=1000
ARG dotfiles=dotfiles.git
ARG userspace=userspace.git
ARG vcsprovider=github.com
ARG vcsowner=stanchiu224

USER root


RUN \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade --no-cache && \
    apk add --update --no-cache \
        sudo \
        autoconf \
        automake \
        libtool \
        nasm \
        ncurses \
        ca-certificates \
        libressl \
        bash-completion \
        cmake \
        ctags \
        file \
        curl \
        build-base \
        gcc \
        coreutils \
        wget \
        neovim \
        git git-doc \
        zsh \
        docker \
        docker-compose \
	python3 \
        python3-dev \
        nodejs \
        npm \
        yarn


RUN \
    echo "%${group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    adduser -D -G ${group} ${user} && \
    addgroup ${user} docker

COPY ./ /home/${user}/.userspace/
RUN \
    git clone --recursive https://${vcsprovider}/${vcsowner}/${dotfiles} /home/${user}/.dotfiles && \
    chown -R ${user}:${group} /home/${user}/.dotfiles && \
    chown -R ${user}:${group} /home/${user}/.userspace
    # For advanced configuration where you would do ssh-agent and gpg-agent passthrough
    # cd /home/${user}/.userspace && \
    # git remote set-url origin git@${vcsprovider}:${vcsowner}/${userspace} && \
    # cd /home/${user}/.dotfiles && \
    # git remote set-url origin git@${vcsprovider}:${vcsowner}/${dotfiles}

# Azure-CLI installation command
RUN	curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN apk add --no-cache zsh

USER ${user}

RUN \
    cd $HOME/.dotfiles && \
    ./install-profile default && \
    cd $HOME/.userspace && \
    ./install-standalone \
        zsh-dependencies \
        zsh-plugins \
        vim-dependencies \
        vim-plugins 

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt


ENV HISTFILE=/config/.history

CMD []
