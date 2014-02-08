require_relative '../db'

class Photor::DB
  class Tag < Record
    attr_accessor :name

    def photos
      db.photos.find_by_tag(self.name)
    end
  end
end
