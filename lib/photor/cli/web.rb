require 'thor'
require_relative '../db'
require_relative '../db/photos'
require_relative '../db/photo'
require_relative '../db/tags'
require_relative '../db/tag'

class Photor::CLI < Thor
  desc "web",
    "generate a website from database cache"
  method_option :dir, type: :string, default: '.', desc: "location of photos and sqlite3 db"
  def web
    db = Photor::DB.new(options[:dir])

    db.tags.all.each do |tag|
      puts "## #{tag.name}"
      tag.photos.sort_by(&:taken_at).each do |photo|
        other_tags = photo.tags.map(&:name) - [tag.name]

        print photo.filename
        print " (#{other_tags.sort.join(', ')})" if other_tags.any?
        print "\n"
      end
      puts ''
    end

    # db.photos.years.each do |year|
    #   Year.new(db, year).generate
    #   12.times do |month|
    #     Month.new(db, year, month + 1).generate
    #     31.times do |day|
    #       Day.new(db, year, month, day + 1).generate
    #     end
    #   end
    # end

  end

  Day = Struct.new(:db, :year, :month, :day)
  class Day
    # all photos
    def photos
      db.photos.find_between("#{year}-#{month}-#{day} 00:00:00", "#{year}-#{month}-#{day} 23:59:59")
    end
  end

  Month = Struct.new(:db, :year, :month)
  class Month
    # select a few random photos
    # display a photo stack of thumbnails
    def photos
      # TEST: what happens in february?
      db.photos.find_between("#{year}-#{month}-01 00:00:00", "#{year}-#{month}-31 23:59:59")
    end
  end

  Year = Struct.new(:db, :year)
  class Year
    # select a few random photos
    # display a photo stack of thumbnails
    def photos
      db.photos.find_between("#{year}-01-01 00:00:00", "#{year}-12-31 23:59:59")
    end
  end

  Tag = Struct.new(:db, :tag)
  class Tag
    # all photos
  end

  TagIndex = Struct.new(:db)
  class TagIndex
    # list of tags
  end
end
