require 'thor'
require_relative '../db'
require_relative '../db/photos'
require_relative '../db/photo'

class Photor::CLI < Thor

  desc "index [DESTINATION]",
    "indexes metadata about photos in DESTINATION"
  long_desc <<-DESC
    Recursively searches DESTINATION directory for all JPEGs, and records metadata
    useful for future searching, tagging, and de-duping.

    All metadata is stored in a SQLite database in the DESTINATION's root. This
    means the db can be archived and accessed with the photos, by multiple clients
    (but not concurrently).

    When possible, the database should strive to be an index of data that already
    exists in photo headers (e.g. EXIF).
  DESC
  def index(destination)
    db = Photor::DB.new(destination)
    Photor.each_jpeg(destination) do |jpg|
      print "."

      photo = db.photos.find_or_create(jpg.name, jpg.taken_at)
      photo.tags = jpg.tags
    end
    puts "\n"
  end

end
