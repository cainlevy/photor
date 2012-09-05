module Photor
  class Searcher
    def initialize(source)
      @source = source
    end

    def run(options = {})
      options[:tags] ||= []
      options[:tags] = options[:tags].map(&:downcase)

      Photor.each_jpeg(@source) do |jpg|
        next unless jpg.exif['Keywords']
        matches = options[:tags] & jpg.exif['Keywords'].map(&:downcase)
        next if matches.empty?

        puts jpg.path
      end
    end
  end
end