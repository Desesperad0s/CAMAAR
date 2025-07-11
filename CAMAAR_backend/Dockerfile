FROM ruby:3.4.3

RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev nodejs

WORKDIR /app

COPY . /app

RUN gem install bundler:1.15.0

RUN bundle install

EXPOSE 3333

CMD rm -f /app/tmp/pids/server.pid && rails server -b 0.0.0.0