FROM ruby:alpine
MAINTAINER Jannik.Hollenbach@iteratec.de

RUN apk update && apk upgrade && apk add perl perl-net-ssleay make g++ openssl

WORKDIR /sectools/

RUN wget https://github.com/sullo/nikto/archive/master.tar.gz -P /sectools && \
    tar zxvf /sectools/master.tar.gz -C /sectools && \
    rm /sectools/master.tar.gz

COPY Gemfile src/

RUN bundle install --gemfile=/sectools/src/Gemfile

COPY src/ src/
COPY lib/ lib/

RUN addgroup -S nikto_group && adduser -S -g nikto_group nikto_user
USER nikto_user

EXPOSE 8080

ARG COMMIT_ID=unkown
ARG REPOSITORY_URL=unkown
ARG BRANCH=unkown

ENV SCB_COMMIT_ID ${COMMIT_ID}
ENV SCB_REPOSITORY_URL ${REPOSITORY_URL}
ENV SCB_BRANCH ${BRANCH}

ENTRYPOINT ["ruby","/sectools/src/main.rb"]
