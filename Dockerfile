FROM ruby:3.2.2-alpine3.18

WORKDIR /home/runner

RUN apk add --update --no-cache docker && \
    gem install --no-document minos
