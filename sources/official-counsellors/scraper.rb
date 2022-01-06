#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def empty?
      raw_name.empty?
    end

    def name
      raw_name.gsub('Premier ', '')
    end

    def position
      raw_name.include?('Premier') ? 'Premier' : 'State Councillor'
    end

    private

    def raw_name
      noko.text.tidy
    end
  end

  class Members
    def member_container
      noko.css('.policy-right .state-one,.state-three a')
    end

    def member_items
      super.reject(&:empty?)
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv if file.exist? && !file.empty?
