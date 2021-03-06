![Intro](./imgs/intro.gif)

## Background
Sometime, when refactoring a legacy codebase, we need confirming/comparing response/payload of before and after refactoring.
It should be better if there is no changed of responses/payloads.

This tool is used for comparing output of requests (in same url's path but different servers mostly) when new version of source code was released and the old one.

## Install

* From source code

```
$git clone https://github.com/manhdaovan/rediff.git
$cd rediff
$gem install bundle
$bundle install
# Then you can set an alias to shortcut command:
$alias rediff="$(which bundle) exec ruby rediff.rb"
```

* From docker

```
$docker pull manhdaovan/rediff
$docker run -it manhdaovan/rediff bash
#
# Or mount output to host machine directory:
# $docker run -it -v /host/machine/output:/workspace/output manhdaovan/rediff bash
# Then you can open ouput file from /host/machine/output directory in your host machine
#
# You can use rediff command inside container
$rediff action [urls] [options]
```

## Usage
The cookie(s) would be sent over each request, so you should login to get cookies first,
then you can request to urls that require authentication legally.

Firstly, Rediff requests to login page, and extracts necessary authenticity token, form action and form method from form html tag, then send authentication info to extracted action path to login.

So, with login action, you should give the login screen url to Rediff like this:

`$bundle exec ruby rediff.rb login https://example-old-code.com/user/login https://example-new-code.com/user/login -p "username=example&password=123456"`

You can login to each url separately:

```
$bundle exec ruby rediff.rb login https://example-old-code.com/user/login -p "username=example11&password=password11"
$bundle exec ruby rediff.rb login https://example-new-code.com/user/login -p "username=example22&password=password22"
```

After login successed, the cookie(s) would be saved to file. And then, it would be sent over each request.

In general:

`$bundle exec ruby rediff.rb action [urls] [options]`

```
ACTION
    The action of operation.
    Available actions are login|diff|clear_cookies

URLS
    The URL syntax is protocol-dependent. You'll find a detailed description in RFC 3986.
    You can specify multiple URLs continuously like:

    $ruby rediff.rb diff https://example.com/sign_in https://other-example.com/sign_in [options]
    NOTE: if action is clear_cookies then url can be 'all' for clear all saved cookies
    Eg: $bundle exec ruby rediff.rb clear_cookies all [options]

OPTIONS
       Options start with one or two dashes. Many of the  options  require  an
       additional value next to them following by "=".

       -i, --input=<input>
              Input source for diff checking.
              Available methods: file|request
              Default is request.
              Eg: rediff diff -i file /path/to/file1.json /path/to/file2.json

       -m, --method=<method>
              HTTP(s) method would be used to request to servers.
              Available methods: get|post|put

       -p, --params=<request params>
              Params would be used in request.
              Eg: --params="user[email]=email@example.com&password=123456"

       -f, --format=<format>
              Format of output with compatible viewing.
              Available formats: color|text|html|html_simple
              color: export to stdio with colors
              text: open output in text editor
              html_simple: open output in browser
              html: same as html_simple

       --auth-token-attr=<auth token attr>
              Attribute of html input tag that contains authenticity token.
              Default: "authenticity_token" that means input as bellow:
              <input name="authenticity_token" value="authenticity_token_value" />

       --form-action-attr=<form action attr>
              Attribute of html form tag that contains form action.
              Default: "action" that means form as bellow:
              <form action="/action_value" />

       --form-method-attr=<form method attr>
              Attribute of html form tag that contains form method.
              Default: "method" that means form as bellow:
              <form method="/method_value" />

       -v, --verbose
              Output executed steps verbosely
```

Run `$bundle exec ruby rediff.rb --help` for more details.

## Some screenshots

### View diff in terminal directly
`$bundle exec ruby rediff.rb diff http://localhost:3000/html http://localhost:4000/html`

![View diff in terminal directly](./imgs/diff_terminal_html.png)

### View diff in html format (github like)
`$bundle exec ruby rediff.rb diff http://localhost:3000/html http://localhost:4000/html --format=html`

![View diff in html format (github like)](./imgs/diff_html_html.png)

`$bundle exec ruby rediff.rb diff http://localhost:3000/json http://localhost:4000/json --format=html`

![View diff in html format (github like)](./imgs/diff_html_json.png)

## TODO
* [x] Add response time of each request
* [x] Support viewing json format in tree mode
* [ ] Unit tests
