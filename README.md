# Skimlinks

[![Build Status](https://secure.travis-ci.org/krautcomputing/skimlinks.png)](http://travis-ci.org/krautcomputing/skimlinks)
[![Dependency Status](https://gemnasium.com/krautcomputing/skimlinks.png)](https://gemnasium.com/krautcomputing/skimlinks)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/krautcomputing/skimlinks)

A simple wrapper around the [Skimlinks APIs](http://skimlinks.com/apis)

## Requirements

Requires Ruby 1.9.2 or higher

## Installation

Add this line to your application's Gemfile:

    gem 'skimlinks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install skimlinks

## Usage

Skimlinks offers the following APIs:

* The [Product API](http://api-products.skimlinks.com/doc/) to search for products and product categories
* The [Merchant API](http://api-merchants.skimlinks.com/doc/) to search for merchants and merchant categories
* The [Link API](http://go.redirectingat.com/doc/) to convert regular URLs into affiliate URLs
* The [Reporting API](https://api-reports.skimlinks.com/doc/) to receive a history of your earned commissions

This gem currently only implements access to the Product API and Merchant API.

## TODO

* Implement access to Link API and Reporting API

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
