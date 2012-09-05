module Photor
  class Searcher
    def initialize(source)
      @source = source
    end

    def run(options = {})
      options[:tags] ||= []
      options[:tags] = options[:tags].map(&:downcase)

      Photor.each_jpeg(@source) do |jpg|
        exif_tags = Array(jpg.exif['Keywords'] || jpg.exif['Subject']).map(&:downcase)
        next if (options[:tags] & exif_tags).empty?

        puts jpg.path
      end
    end
  end
end