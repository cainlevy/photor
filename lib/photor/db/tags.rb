require_relative '../db'
require_relative 'tag'

class Photor::DB
  class Tags < Table
    NAME = 'tags'
    COLUMNS = %w(id name)

    def all
      select_all(Tag, "SELECT #{COLUMNS.join(', ')} FROM #{NAME} ORDER BY name ASC")
    end

    def find_by_photo(photo)
      select_all(Tag, <<-SQL, photo.id)
        SELECT #{COLUMNS.map{|c| [NAME, c].join('.') }.join(', ')}
        FROM #{NAME}
        INNER JOIN taggings ON taggings.tag_id = #{NAME}.id
        WHERE taggings.photo_id = ?
      SQL
    end
  end
end
