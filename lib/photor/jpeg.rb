begin
  require 'exifr'
rescue LoadError
  puts "please run `gem install exifr`"
  exit
end

module Photor
  class JPEG < Photo
    def taken_at
      exif.date_time
    end

    private

    def exif
      @exif ||= EXIFR::JPEG.new(path)
    end
  end
end