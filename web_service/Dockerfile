FROM ruby:2.7.2

ENV USER="user"
ENV RAILS_ENV="production"

RUN useradd -ms /bin/bash $USER
WORKDIR /home/$USER

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]