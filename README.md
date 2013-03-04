# Skimlinks

[![Build Status](https://secure.travis-ci.org/krautcomputing/skimlinks.png)](http://travis-ci.org/krautcomputing/skimlinks)
[![Dependency Status](https://gemnasium.com/krautcomputing/skimlinks.png)](https://gemnasium.com/krautcomputing/skimlinks)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/krautcomputing/skimlinks)
[![Gem Version](https://badge.fury.io/rb/skimlinks.png)](http://badge.fury.io/rb/skimlinks)

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

## APIs

Skimlinks offers the following APIs:

* The [Product API](http://api-products.skimlinks.com/doc/) to search for products and product categories
* The [Merchant API](http://api-merchants.skimlinks.com/doc/) to search for merchants and merchant categories
* The [Link API](http://go.redirectingat.com/doc/) to convert regular URLs into affiliate URLs
* The [Reporting API](https://api-reports.skimlinks.com/doc/) to receive a history of your earned commissions

This gem currently only implements access to the Product API and Merchant API.

## Usage

### Configuration

Add configurations to `config/initializers/skimlinks.rb`:

```ruby
Skimlinks.configure do |config|
  config.api_key   = 'foobar'       # Your API key (get it here: https://accounts.skimlinks.com/productapi) (mandatory)
  config.cache     = Rails.cache    # Set to an instance of ActiveSupport::Cache::Store to cache the API requests. (optional, defaults to nil)
  config.format    = :json          # Currently no other setting is supported. In the future it will be possible to set this to :xml to communicate with the API via XML. (optional, defaults to :json)
  config.cache_ttl = 10.minutes     # Set to higher/lower value to cache requests shorter/longer. (optional, defaults to 1 day)
end
```

### Product API

#### Get a list of product categories

```ruby
Skimlinks::ProductSearch.new.categories

=> {
=>   "Animals"                                                      => 1, # Category name => category ID
=>   "Animals > Live Animals"                                       => 2,
=>   "Animals > Pet Supplies"                                       => 3,
=>   "Animals > Pet Supplies > Bird Supplies"                       => 4,
=>   "Animals > Pet Supplies > Bird Supplies > Bird Cages & Stands" => 5,
=>   "Animals > Pet Supplies > Bird Supplies > Bird Food"           => 6,
=>   ...
=> }
```

#### Get a nested list of product categories

```ruby
Skimlinks::ProductSearch.new.nested_categories

=> {
=>   "Animals" => {
=>     "Live Animals" => nil,
=>     "Pet Supplies" => {
=>       "Bird Supplies" => {
=>         "Bird Cages & Stands" => nil,
=>         "Bird Food"           => nil,
=>         ...
=>       }
=>     }
=>   }
=> }
```

#### Search for products

```ruby
Skimlinks::ProductSearch.new(
  query:       'justin bieber', # Search query                                               (mandatory)
  page:        1,               # Page                                                       (optional, defaults to 1)
  rows:        10,              # Number of rows to return                                   (optional, max. 300, defaults to 10)
  min_price:   100,             # Minimum price (including decimal digits, i.e. 100 = $1.00) (optional)
  max_price:   500,             # Maximum price (including decimal digits, i.e. 500 = $5.00) (optional)
  locale:      'uk',            # Restrict search to products with a certain locale          (optional)
  merchant_id: 8286,            # Restrict search to products of a specific merchant         (optional)
  category:    'Toys & Games'   # Restrict search to products in a certain category          (optional)
).products

=> [
=>   #<Skimlinks::Product:0x00000103e13bc0 @id="16378111", @name="Justin Bieber (Live) Poster", @url="http://www.play.com/Product.aspx?r=GADG&title=20468288", @description="Justin Bieber (Live) Poster", @merchant="Play.com", @country="UK", @price=299, @currency="gbp", @category="Toys & Games", @image_urls=[#<URI::HTTP:0x00000103e13cb0 URL:http://images.productserve.com/preview/1418/153122801.jpg>]>,
=>   #<Skimlinks::Product:0x00000103cc4008 @id="177518521", @name="Justin Bieber Boyfriend Poster", @url="http://www.play.com/Product.aspx?r=GADG&title=33428272", @description="Justin Bieber (Boyfriend)", @merchant="Play.com", @country="UK", @price=299, @currency="gbp", @category="Toys & Games", @image_urls=[#<URI::HTTP:0x00000103cc41e8 URL:http://images.productserve.com/preview/1418/569238291.jpg>]>,
=>   #<Skimlinks::Product:0x00000103b66940 @id="16365811", @name="Justin Bieber (Hoodie) Mini Poster", @url="http://www.play.com/Product.aspx?r=GADG&title=20418241", @description="Justin Bieber (Hoodie) Mini Poster", @merchant="Play.com", @country="UK", @price=299, @currency="gbp", @category="Toys & Games", @image_urls=[#<URI::HTTP:0x00000103b66a80 URL:http://images.productserve.com/preview/1418/148546541.jpg>]>,
=>   ...
=> ]
```

### Merchant API

#### Search for merchants

```ruby
Skimlinks::MerchantSearch.new(
  category_ids: [1, 2, 3] # Return only merchants in the specificed categories (optional)
).merchants

=> [
=>   #<Skimlinks::Merchant:0x00000103d33b60 @id=17738, @name="*NEW!* High Commission Payout!", @preferred={}, @updated_at=2012-12-16 01:02:00 +0100, @average_conversion_rate="0", @average_commission="0", @logo_url="http://s.skimresources.com/logos/17738.jpg", @domains={"9682"=>"mykegelsecret.com", "45143"=>"kegelmasters.com"}, @categories={"37"=>"health & beauty", "1"=>"adult & mature", "38"=>"health & beauty;cosmetics", "39"=>"health & beauty;health products"}, @countries=["united states"], @product_count=0>,
=>   #<Skimlinks::Merchant:0x00000103cd7428 @id=41004, @name="Adultsextoys.com - A Huge Range Of Adult Products", @preferred={}, @updated_at=2012-12-16 01:02:00 +0100, @average_conversion_rate="0", @average_commission="0", @logo_url="http://s.skimresources.com/logos/41004.jpg", @domains={"40457"=>"adultsextoys.com.au"}, @categories={"1"=>"adult & mature"}, @countries=["australia"], @product_count=0>,
=>   #<Skimlinks::Merchant:0x00000103cb2dd0 @id=68079, @name="Adultshop", @preferred={}, @updated_at=2012-12-16 01:02:00 +0100, @average_conversion_rate="0", @average_commission="0", @logo_url="http://s.skimresources.com/logos/68079.jpg", @domains={"68133"=>"shop.adultshop.de"}, @categories={"1"=>"adult & mature"}, @countries=["germany"], @product_count=0>,
=>   ...
=> ]
```

#### Get a single merchant

```ruby
Skimlinks::MerchantSearch.new.merchant(
 12678 # Merchant ID, get it from calling Skimlinks::MerchantSearch.merchants first (mandatory)
)

=> #<Skimlinks::Merchant:0x00000105204f30 @id=12678, @name="Amazon US", @preferred={"commission"=>"8.5% General products\r\n4% Electronics", "commissionDetails"=>"Was 6% --&gt; NOW 8.5% General products!\r\nWas 3% --&gt; NOW 4% Electronics!", "description"=>"Amazon.com is the global leader in e-commerce.  They launch new product categories and stores around the world as it offers customers greater selection, lower prices, more in-stock merchandise, and a best-in-class shopping experience.", "ecpc"=>"0.00", "featured_commission"=>nil, "pp_enabled"=>"1"}, @updated_at=2012-12-07 01:02:00 +0100, @average_conversion_rate="5.42%", @average_commission="6.36%", @logo_url="http://s.skimresources.com/logos/12678.jpeg", @domains={"6309"=>"amazon.com", "47172"=>"wireless.amazon.com", "119814"=>"amazonsupply.com"}, @categories={"12"=>"consumer electronics;mobiles, pdas & satnav", "50"=>"phones, tv & broadband subscriptions", "8"=>"consumer electronics", "9"=>"consumer electronics;audio, tv & home theatre", "10"=>"consumer electronics;cameras & photos", "11"=>"consumer electronics;gadgets & geeks", "13"=>"consumer electronics;mp3 players & accessories", "18"=>"fashion & accessories", "19"=>"fashion & accessories;belts & bags", "20"=>"fashion & accessories;children's clothing", "21"=>"fashion & accessories;jewelry", "22"=>"fashion & accessories;lingerie & sleepwear", "23"=>"fashion & accessories;men's clothing", "24"=>"fashion & accessories;shoes", "25"=>"fashion & accessories;women's clothing", "33"=>"gifts", "34"=>"gifts;chocolate", "35"=>"gifts;flowers", "36"=>"gifts;novelty", "40"=>"home & garden", "41"=>"home & garden;bed & bath", "42"=>"home & garden;diy", "43"=>"home & garden;furniture & interior design", "44"=>"home & garden;garden", "45"=>"home & garden;home appliances", "37"=>"health & beauty", "38"=>"health & beauty;cosmetics", "39"=>"health & beauty;health products"}, @countries=["united states"], @product_count=0>
```

#### Get a list of merchant categories

```ruby
Skimlinks::MerchantSearch.new.categories

=> {
=>   "adult & mature"                                  => 1, # Category name => category ID
=>   "arts, crafts & hobbies"                          => 2,
=>   "automotive, cars & bikes"                        => 3,
=>   "baby & parenting supplies"                       => 4,
=>   "books & magazines"                               => 5,
=>   "charities & non-profit"                          => 6,
=>   "computers & software"                            => 7,
=>   "consumer electronics"                            => 8,
=>   "consumer electronics > audio, tv & home theatre" => 9,
=>   "consumer electronics > cameras & photos"         => 10,
=>   ...
=> }
```

#### Get a nested list of merchant categories

```ruby
Skimlinks::MerchantSearch.new.nested_categories

=> {
=>   "adult & mature"            => nil,
=>   "arts, crafts & hobbies"    => nil,
=>   "automotive, cars & bikes"  => nil,
=>   "baby & parenting supplies" => nil,
=>   "books & magazines"         => nil,
=>   "charities & non-profit"    => nil,
=>   "computers & software"      => nil,
=>   "consumer electronics"      => {
=>     "audio, tv & home theatre"  => nil,
=>     "cameras & photos"          => nil,
=>     ...
=>   }
=> }
```

## TODO

* Implement access to Link API and Reporting API

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
