FROM ruby:2.5.3-alpine3.7

WORKDIR /home/runner

RUN apk add --update --no-cache docker && \
    gem install --no-document minos
