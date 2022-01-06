#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def empty?
      position == 'Position'
    end

    def name
      tds[1].text.tidy
    end

    def position
      tds[0].text.tidy
    end

    private

    def tds
      noko.css('td')
    end
  end

  class Members
    def member_container
      noko.xpath('//table[.//tr[contains(.,"Current Holder")]]//tr[td]')
    end

    def member_items
      super.reject(&:empty?)
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv if file.exist? && !file.empty?
