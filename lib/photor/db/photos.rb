require_relative '../db'
require_relative 'photo'

class Photor::DB
  class Photos < Table
    NAME = 'photos'
    COLUMNS = %w(id filename taken_at)

    def find(filename, taken_at)
      select(Photo, "SELECT #{COLUMNS.join(', ')} FROM #{NAME} WHERE filename = ? AND taken_at = ?", filename, taken_at.to_i)
    end

    def find_by_tag(tag)
      select_all(Photo, <<-SQL, tag)
        SELECT #{COLUMNS.map{|c| [NAME, c].join('.') }.join(', ')}
        FROM #{NAME}
        INNER JOIN taggings ON taggings.photo_id = photos.id
        INNER JOIN tags ON taggings.tag_id = tags.id
        WHERE tags.name = ?
      SQL
    end

    def find_in_time_range(t1, t2)
      select_all(Photo, <<-SQL, t1.to_i, t2.to_i)
        SELECT #{COLUMNS.map{|c| [NAME, c].join('.' )}.join(', ')}
        FROM #{NAME}
        WHERE taken_at BETWEEN ? AND ?
      SQL
    end

    def years
      db.conn.execute(<<-SQL).flatten.sort
        SELECT DISTINCT STRFTIME('%Y', taken_at, 'unixepoch')
        FROM #{NAME}
      SQL
    end

    def create(filename, taken_at)
      db.conn.execute("INSERT INTO #{NAME} (#{COLUMNS.join(', ')}) VALUES (NULL, ?, ?)", filename, taken_at.to_i)
      Photo.new(db, {'id' => db.conn.last_insert_row_id, 'filename' => filename, 'taken_at' => taken_at.to_i})
    end

    def find_or_create(filename, taken_at)
      find(filename, taken_at) || create(filename, taken_at)
    end
  end
end
