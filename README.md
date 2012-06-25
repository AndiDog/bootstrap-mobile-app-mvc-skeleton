# Brunch with CoffeeScript, jQuery Mobile, Backbone, Handlebars and Stylus, using the MVC pattern
This is a skeleton for [Brunch](http://brunch.io/) based on the work of Paul Millr ([simple-coffee-skeleton](https://github.com/brunch/simple-coffee-skeleton)).

Main languages are [CoffeeScript](http://coffeescript.org/),
[Stylus](http://learnboost.github.com/stylus/) and
[Handlebars](http://handlebarsjs.com/).

## Getting started

Clone this repo or download the ZIP file (you won't need the history). Then run `npm install` in that directory, followed by `brunch build` (or `brunch w -s` for automatic rebuilding on changes and Brunch's integrated web server). See more info on the [official site of Brunch](http://brunch.io).

## License
[Public domain](http://creativecommons.org/publicdomain/zero/1.0/) – use it however you want.

## Overview

    config.coffee
    README.md
    /app/
      /assets/
        index.html
        images/
      /lib/
      models/
      styles/
      views/
        templates/
      application.coffee
      initialize.coffee
    /test/
      functional/
      unit/
    /vendor/
      scripts/
        backbone.js
        jquery.js
        console-helper.js
        underscore.js
      styles/
        normalize.css
        helpers.css

* `config.coffee` contains configuration of your app. You can set plugins /
languages that would be used here.
* `app/assets` contains images / static files. Contents of the directory would
be copied to `build/` without change.
Other `app/` directories could contain files that would be compiled. Languages,
that compile to JS (coffeescript, roy etc.) or js files and located in app are
automatically wrapped in module closure so they can be loaded by
`require('module/location')`.
* `app/models` & `app/views` contain base classes your app should inherit from.
* `app/controllers` contains example controllers using Backbone's hashbang routing
* `test/` contains feature & unit tests.
* `vendor/` contains all third-party code. The code wouldn’t be wrapped in
modules, it would be loaded instantly instead.

This all will generate `public/` (by default) directory when `brunch build` or `brunch watch` is executed.

## Other
Versions of software the skeleton uses:

* jQuery 1.7.2
* Backbone 0.9.2
* Underscore 1.3.3
* jQuery Mobile 1.1.0 (with default theme)