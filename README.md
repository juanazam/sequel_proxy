# SequelProxy

Small gem to proxy Sequel queries to do post or after processing for general purposes.

Heavily inspired on [arproxy](https://github.com/cookpad/arproxy) (Thanks!)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel_proxy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel_proxy

## Usage

```ruby
require 'sequel_proxy'

class SimpleProxy < SequelProxy::BaseProxy
  def execute(sql, opts = nil, &block)
    puts "Proxied"
    super
  end
end

SequelProxy.configure do |config|
  config.adapter Sequel::MySQL::Database
  config.use SimpleProxy
end

SequelProxy.enable!

MyModel.where(label: "label").first
# => Proxied
# => Query Result
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sequel_proxy.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
