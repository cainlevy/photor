require 'thor'
require_relative '../db'
require_relative '../db/photos'
require_relative '../db/photo'

class Photor::CLI < Thor

  desc "search [SOURCE]",
    "finds photos in SOURCE that match specified criteria"
  long_desc <<-DESC
    Uses the index database to find photos matching all criteria.
  DESC
  method_option :tags, :type => :array, :desc => "only show files with matching tags"
  def search(source)
    tags = Array(options[:tags]).map(&:downcase)

    db = Photor::DB.new(source)

    photo_sets = []
    tags.each{|t| photo_sets << db.photos.find_by_tag(t) }
    photos = photo_sets.inject(photo_sets.first, :&)

    photos.each do |p|
      puts Photor.path(p.taken_at, p.filename)
    end
  end

end
