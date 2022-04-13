#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderNonTable < OfficeholderListBase::OfficeholderBase
  def empty?
    false
  end

  def combo_date?
    true
  end

  def raw_combo_date
    raise 'need to define a raw_combo_date'
  end

  def name_node
    raise 'need to define a name_node'
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//h2[.//span[contains(.,'Governors')]][last()]//following::ol[1]//li[a]")
  end

  class Officeholder < OfficeholderNonTable
    def name_node
      noko.css('a')
    end

    def raw_combo_date
      noko.text.split(':').last.gsub(/\(.*\)/, '').tidy
    end

    # TODO: push up
    def raw_combo_dates
      raw_combo_date.split(/[－—–-]/).map(&:tidy)
    end
      
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
