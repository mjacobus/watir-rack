# Watir::Rack
[![Gem Version](https://badge.fury.io/rb/watir-rack.png)](http://badge.fury.io/rb/watir-rack)
[![Build Status](https://api.travis-ci.org/mjacobus/watir-rack.png)](http://travis-ci.org/mjacobus/watir-rack)
[![Coverage](https://coveralls.io/repos/mjacobus/watir-rack/badge.png?branch=master)](https://coveralls.io/r/mjacobus/watir-rack)

This gem makes [Watir](https://github.com/watir/watir) work with any Rack App.

## Installation

Add this code to your Gemfile:

```ruby
group :test do
  gem "watir-rack"
end
```

## Usage

Just use Watir like you've always done in your requests/integration tests:

```ruby
Watir::Rack.app = Hanami.app

browser = Watir::Browser.new
browser.goto home_path
browser.text_field(name: "first").set "Jarmo"
browser.text_field(name: "last").set  "Pertman"
browser.button(name: "sign_in").click
```

## Limitations

* This is a [quick] adaptation of [watir-rails](https://github.com/watir/watir-rails). All the heavy lifting was done by those folks.


## Contributors

* [Jarmo Pertman](https://github.com/jarmo)
* [Alex Rodionov](https://github.com/p0deje)
* [Marcelo Jacobus](https://github.com/mjacobus)


## License

See [LICENSE](https://github.com/mjacobus/watir-rack/blob/master/LICENSE).
