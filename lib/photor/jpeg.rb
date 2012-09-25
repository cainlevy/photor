module Photor
  class JPEG < Photo
    def taken_at
      exif.date_time || super
    end

    def exif
      @exif ||= Photor::Exif.new(path)
    end

    def tags
      Array(exif['Keywords']) + Array(exif['Subject'])
    end
  end
end