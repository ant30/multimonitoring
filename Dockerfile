FROM ruby:2.1.5

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV GEM_HOME /usr/local/bundle

WORKDIR /usr/src/app
ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/

RUN gem install foreman

RUN bundle

EXPOSE 3000
CMD ["foreman start -f Procfile"]
