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

    class Table
      attr_accessor :db
      def initialize(db)
        @db = db
      end
    end

    class Record
      attr_accessor :db, :id
      def initialize(db, attributes)
        @db = db
        attributes.each{|k, v| send("#{k}=", v)}
      end
    end
  end
end
