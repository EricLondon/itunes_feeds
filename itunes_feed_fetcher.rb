
require 'rubygems'
require 'curb'
require 'nokogiri'
require 'nori'

require './mongo.rb'

class ItunesFeedFetcher

  def initialize
    @feed_count = 300
    @feed_url = "https://itunes.apple.com/us/rss/toppaidapplications/limit=#{@feed_count}/xml"
    @feed_items_new = 0
    @feed_items_updated = 0
  end

  def fetch

    # curl feed url
    curld = Curl::Easy.perform @feed_url

    # convert rss feed xml to hash
    nori = Nori.new(:parser => :nokogiri)
    @feed_data = nori.parse curld.body_str

  end

  def process

    return nil if @feed_data.nil?

    @feed_data['feed']['entry'].each do |entry|

      # get itunes id
      itunes_id = entry['id']

      # check if entry exists in database
      existing = FeedItem.where(itunes_id: itunes_id).first

      if !existing.nil?

        # check if entry has been updated
        if entry['updated'].utc >= existing['updated'].utc
          # todo: update entry details
        end

        # get entry price, minus dollar sign
        entry_price = entry['im:price'].scan(/[0-9.]+/).first

        # create feed item price record
        fip = existing.feedItemPrices.create({created: Time.now, price: entry_price})
        fip.save

        @feed_items_updated += 1

      else

        # get entry price, minus dollar sign
        entry_price = entry['im:price'].scan(/[0-9.]+/).first

        # remove entry price, will be embedded instead
        entry.delete 'im:price'

        # set itunes id to entry
        entry['itunes_id'] = itunes_id

        # create new feed item record
        fi = FeedItem.new entry
        fi.save

        # create feed item price record
        fip = fi.feedItemPrices.create({created: Time.now, price: entry_price})
        fip.save

        @feed_items_new += 1

      end

    end

  end

  def report
    "New: #{@feed_items_new}<br/>Updated: #{@feed_items_updated}"
  end

end
