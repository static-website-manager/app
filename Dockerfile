FROM ruby:2.2.3
RUN apt-get update -qq && apt-get install -y build-essential cmake nodejs
ENV home /app
RUN mkdir $home
WORKDIR $home
COPY Gemfile $home/Gemfile
COPY Gemfile.lock $home/Gemfile.lock
RUN bundle install
COPY . $home
