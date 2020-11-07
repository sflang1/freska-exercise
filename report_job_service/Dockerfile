FROM ruby:2.7.2

ENV USER="user"

RUN useradd -ms /bin/bash $USER
WORKDIR /home/$USER

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .
