## Background

This tool is used for comparing output of request (in same url's path but different servers mostly) when new version of source code was released and the old one.

## Install

```
git clone https://github.com/manhdaovan/rediff.git
cd rediff
gem install bundle
bundle install
```

## Usage
See `$bundle exec ruby rediff.rb --help`

## TODO
* [ ] Add response time of each request
* [ ] Support viewing json format in tree mode
