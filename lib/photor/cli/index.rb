require 'thor'
require_relative '../db'
require_relative '../db/photos'
require_relative '../db/photo'

class Photor::CLI < Thor

  desc "index",
    "indexes photo metadata into a read-only database cache"
  long_desc <<-DESC
    Recursively searches for all JPEGs, and records metadata useful for future
    searching, tagging, and de-duping.

    All metadata is stored in a SQLite database. This means the db can be archived
    and accessed with the photos, by multiple clients (but not concurrently).

    The database only caches metadata from each photo, to speed up certain
    operations. The photo headers (e.g. EXIF) are still the canonical data source.
  DESC
  method_option :dir, :type => :string, :default => '.', :desc => "location of photos and sqlite3 db"
  def index
    db = Photor::DB.new(options[:dir])
    puts "indexing photos since #{db.mtime}" if db.mtime
    Photor.each_jpeg(options[:dir], since: db.mtime) do |jpg|
      print "."

      photo = db.photos.find_or_create(jpg.name, jpg.taken_at)
      photo.tags = jpg.tags
    end
    puts "\n"
  end

end
