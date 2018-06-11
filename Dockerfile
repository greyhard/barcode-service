FROM perl:5.26
MAINTAINER greyhard@gmail.com

RUN apt-get update

RUN apt-get install -y curl make gcc cmake

RUN curl -L http://cpanmin.us | perl - App::cpanminus

RUN cpanm Mojolicious Mojolicious::Plugin::Database

COPY service /usr/src/myapp
WORKDIR /usr/src/myapp

CMD [ "hypnotoad", "-f", "/usr/src/myapp/myapp.pl" ]