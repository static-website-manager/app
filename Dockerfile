FROM ruby:2.2.3
RUN apt-get update -qq && apt-get install -y build-essential cmake nodejs
ENV home /rails
RUN mkdir $home
WORKDIR $home
ADD Gemfile $home/Gemfile
ADD Gemfile.lock $home/Gemfile.lock
RUN bundle install
ADD . $home
