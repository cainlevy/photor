require_relative '../db'

class Photor::DB
  class Photos < Table
    def find(filename, taken_at)
      select(Photo, "SELECT id, filename, taken_at FROM photos WHERE filename = ? AND taken_at = ?", filename, taken_at.to_i)
    end

    def find_by_tag(tag)
      select_all(Photo, <<-SQL, tag)
        SELECT photos.id, photos.filename, photos.taken_at
        FROM photos
        INNER JOIN taggings ON taggings.photo_id = photos.id
        INNER JOIN tags ON taggings.tag_id = tags.id
        WHERE tags.name = ?
      SQL
    end

    def create(filename, taken_at)
      db.execute("INSERT INTO photos (id, filename, taken_at) VALUES (NULL, ?, ?)", filename, taken_at.to_i)
      Photo.new(db, {'id' => db.last_insert_row_id, 'filename' => filename, 'taken_at' => taken_at.to_i})
    end

    def find_or_create(filename, taken_at)
      find(filename, taken_at) || create(filename, taken_at)
    end
  end
end
