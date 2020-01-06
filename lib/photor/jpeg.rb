require_relative 'exif'
require_relative 'media'

module Photor
  class JPEG < Media
    FINGERPRINT_LENGTH = 24

    def taken_at
      exif.date_time || super
    end

    def extension
      '.jpg'
    end

    def exif
      @exif ||= Photor::Exif.new(path)
    end

    def tags
      Array(exif['Keywords']) + Array(exif['Subject'])
    end

    def orientation
      exif['Orientation']
    end

    def unique_name
      @unique_name ||= "#{taken_at.strftime "%Y%m%d%H%M%S"}-#{md5[0, FINGERPRINT_LENGTH]}#{extension}"
    end
  end
end
