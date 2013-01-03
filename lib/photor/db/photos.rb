require_relative '../db'

class Photor::DB
  class Photos < Table
    def find(filename, taken_at)
      row = db.get_first_row("SELECT id, filename, taken_at FROM photos WHERE filename = ? AND taken_at = ?", filename, taken_at.to_i)
      row && Photo.new(db, {'id' => row[0], 'filename' => row[1], 'taken_at' => row[2]})
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
