module Photor
  module JPEG
    def taken_at
      exif.date_time || super
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
  end
end
