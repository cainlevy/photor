begin
  require 'exifr'
rescue LoadError
  puts "please run `gem install exifr`"
  exit
end

module Photor
  class JPEG < Photo
    def taken_at
      exif.date_time.respond_to?(:to_time) ?
        exif.date_time :
        super
    end

    private

    def exif
      @exif ||= EXIFR::JPEG.new(path)
    end
  end
end