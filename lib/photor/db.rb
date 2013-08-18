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
      db_path = ::File.join(base_path, FILENAME)
      unless ::File.exists? db_path
        puts "initializing #{db_path}"
        @conn = SQLite3::Database.new(db_path)
        @conn.execute_batch(SCHEMA)
        @conn.execute("INSERT INTO meta (version) VALUES (?)", VERSION)
      end
      @conn ||= SQLite3::Database.new(db_path)
    end

    def photos
      @photos ||= Photos.new(@conn)
    end

    # TODO: find sqlite docs and deprecate result_to_hash by introspecting result set
    class Table
      attr_accessor :db
      def initialize(db)
        @db = db
      end

      private

      def select(klass, *sql)
        row = db.get_first_row(*sql)
        row && klass.new(db, result_to_hash(row))
      end

      def select_all(klass, *sql)
        rows = db.execute(*sql)
        rows.map{|row| klass.new(db, result_to_hash(row))}
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
