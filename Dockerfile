FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get install -y curl git libssl-dev make clang llvm libc++-dev

RUN apt-get install -y tzdata zlib1g-dev

WORKDIR /test
RUN useradd -ms /bin/bash test
RUN chown test /test
USER test

RUN openssl version
RUN ls -l /etc/localtime

# RUN git clone --depth 1 --branch truffleruby-1.0.0-rc3 https://github.com/eregon/rvm.git
ADD . rvm
RUN cd rvm && ./install

# Cache file
ADD truffleruby-1.0.0-rc6-linux-amd64.tar.gz ~/.rvm/archives/truffleruby-1.0.0-rc6-linux-amd64.tar.gz

ENV RVM_SCRIPT=/home/test/.rvm/scripts/rvm
RUN bash -c 'source $RVM_SCRIPT && rvm --version'
RUN bash -c 'source $RVM_SCRIPT && rvm autolibs disable'
RUN bash -c 'source $RVM_SCRIPT && rvm list'
RUN bash -c 'source $RVM_SCRIPT && rvm --debug install truffleruby'
# RUN bash -c 'source $RVM_SCRIPT && rvm --debug --disable-binary install truffleruby'
RUN bash -c 'source $RVM_SCRIPT && rvm list'
RUN bash -c 'source $RVM_SCRIPT && rvm use truffleruby && ruby --version'
RUN bash -c 'source $RVM_SCRIPT && rvm use truffleruby && rake --version'
RUN bash -c 'source $RVM_SCRIPT && rvm use truffleruby && ruby -ropen-uri -e "puts open(%{https://rubygems.org/}) { |f| f.read }[0,1000]"'
