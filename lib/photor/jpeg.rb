module Photor
  class JPEG < Photo
    def taken_at
      exif.date_time || super
    end

    private

    def exif
      @exif ||= Photor::Exif.new(path)
    end
  end
end