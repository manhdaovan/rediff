FROM ruby:2.5-slim
MAINTAINER ManhDV "https://github.com/manhdaovan"

RUN mkdir -p /workspace
ADD ./ /workspace
RUN cd ./workspace && gem install bundle && bundle install
RUN echo 'alias rediff="$(which bundle) exec ruby /workspace/rediff.rb"' >> ~/.bashrc

WORKDIR /workspace
