require 'mongoid'

# load mongo conf
Mongoid.load!('mongoid.yml', :development)

class FeedItem
  include Mongoid::Document
  embeds_many :feedItemPrices
end

class FeedItemPrice
  include Mongoid::Document
  embedded_in :feedItem
end
