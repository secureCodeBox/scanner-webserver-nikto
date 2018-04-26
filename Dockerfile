FROM ruby:alpine
MAINTAINER Jannik.Hollenbach@iteratec.de

RUN apk update && apk upgrade && apk add perl perl-net-ssleay make g++ openssl

RUN gem install sinatra rest-client -N

WORKDIR /sectools/

RUN wget https://github.com/sullo/nikto/archive/master.tar.gz -P /sectools && \
    tar zxvf /sectools/master.tar.gz -C /sectools && \
    rm /sectools/master.tar.gz

COPY src/ src/
COPY lib/ lib/

RUN addgroup -S nikto_group && adduser -S -g nikto_group nikto_user 
USER nikto_user

EXPOSE 8080

ENTRYPOINT ["ruby","/sectools/src/main.rb"]
