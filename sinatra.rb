#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'gchart'

require './mongo.rb'
require './itunes_feed_fetcher.rb'

get '/' do

  output = '<table>'
  FeedItem.each do |fi|
    output += "<tr>"
    output += "<td><img src='#{fi['im:image'][0]}' /></td>"
    output += "<td><b>#{fi['im:name']}</b></td>"
    #output += "<td>#{fi['content']}</td>"

    # collect feed item prices
    prices = fi.feedItemPrices.collect {|fip| fip['price'].to_f}

    prices = (1..25).collect {|i| rand(4)}

    # create google chart image url
    chart_url = Gchart.sparkline(:data => prices, :size => '120x40', :line_colors => '0077CC')
    output += "<td><img src='#{chart_url}' /></td>"

    output += "</tr>"
  end
  output += "</table>"
  output

end

get '/fetch' do
  iff = ItunesFeedFetcher.new
  iff.fetch
  iff.process
  iff.report
end
