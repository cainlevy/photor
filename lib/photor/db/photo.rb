require_relative '../db'

class Photor::DB
  class Photo < Record
    attr_accessor :filename
    attr_accessor :taken_at

    # SET all tags (any tags not listed will be deleted)
    def tags=(*tags)
      tags = tags.flatten.uniq

      db.conn.transaction do |trans|
        trans.execute("DELETE FROM taggings WHERE photo_id = ?", self.id)

        if tags.any?
          values = ['(?)'] * tags.size
          trans.execute("INSERT OR IGNORE INTO tags (name) VALUES #{values.join(', ')}", *tags)

          values = ['(?, (SELECT id FROM tags WHERE name = ?))'] * tags.size
          trans.execute("INSERT INTO taggings (photo_id, tag_id) VALUES #{values.join(', ')}", *tags.map{|t| [self.id, t]}.flatten)
        end
      end
    end

    def tags
      db.tags.find_by_photo(self)
    end

    # TODO: use virtus
    def taken_at
      @taken_at_time ||= Time.at(@taken_at.to_i)
    end
  end
end
