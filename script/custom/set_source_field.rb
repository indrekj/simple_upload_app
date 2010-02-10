#!/usr/bin/env ruby

RAILS_ENV = ENV['RAILS_ENV'] ||= "development"
require File.dirname(__FILE__) + "/../../config/environment"

puts "Started!"

Asset.all.each do |asset|
  asset.determine_source!
  asset.remove_delicate_info!
  if asset.save
    puts "Asset ##{asset.id} saved"
  else
    puts "ERROR: Unable to save asset ##{asset.id}"
  end
end

puts "Finished!"
