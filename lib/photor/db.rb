require 'sqlite3'

module Photor
  class DB
    FILENAME = 'photor.sqlite3'
    VERSION  = 0.99
    SCHEMA   = <<-SQL
      CREATE TABLE meta(
        version TEXT NOT NULL
      );

      CREATE TABLE photos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT NOT NULL,
        taken_at NUMERIC NOT NULL,
        UNIQUE (filename, taken_at)
      );

      CREATE TABLE taggings(
        photo_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        UNIQUE (photo_id, tag_id)
      );

      CREATE TABLE tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE,
        UNIQUE (name)
      );
    SQL

    def initialize(base_path)
      db_path = File.join(base_path, FILENAME)
      unless File.exists? db_path
        puts "initializing"
        @conn = SQLite3::Database.new(db_path)
        @conn.execute_batch(SCHEMA)
        @conn.execute("INSERT INTO meta (version) VALUES (?)", VERSION)
      end
      @conn ||= SQLite3::Database.new(db_path)
    end

    def photos
      @photos ||= Photos.new(@conn)
    end

    Table = Struct.new(:db)

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
        puts filename
        find(filename, taken_at) || create(filename, taken_at)
      end
    end

    class Record
      attr_accessor :db, :id
      def initialize(db, attributes)
        @db = db
        attributes.each{|k, v| send("#{k}=", v)}
      end
    end

    class Photo < Record
      attr_accessor :filename
      attr_accessor :taken_at

      # SET all tags (any tags not listed will be deleted)
      def tags=(*tags)
        tags = tags.flatten

        puts "setting tags for #{self.id} to #{tags.join('|')}"
        db.transaction do |trans|
          trans.execute("DELETE FROM taggings WHERE photo_id = ?", self.id)

          if tags.any?
            values = ['(?)'] * tags.size
            trans.execute("INSERT OR IGNORE INTO tags (name) VALUES #{values.join(', ')}", *tags)

            values = ['(?, (SELECT id FROM tags WHERE name = ?))'] * tags.size
            trans.execute("INSERT INTO taggings (photo_id, tag_id) VALUES #{values.join(', ')}", *tags.map{|t| [self.id, t]}.flatten)
          end
        end
      end
    end
  end
end
