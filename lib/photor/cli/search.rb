require 'thor'

class Photor::CLI < Thor

  desc "search [SOURCE]",
    "finds photos in SOURCE that match specified criteria"
  long_desc <<-DESC
    Recursively searches the SOURCE directory for all JPEGs that match specified
    criteria, such as EXIF tags (aka keywords). Reports each found file, one
    per line.
  DESC
  method_option :tags, :type => :array, :desc => "only show files with matching EXIF keywords"
  def search(source)
    tags = (options[:tags] || []).map(&:downcase)

    Photor.each_jpeg(source) do |jpg|
      exif_tags = jpg.tags.map(&:downcase)
      next if (options[:tags] & exif_tags).empty?

      puts jpg.path
    end
  end

end
