require 'json'
require 'time'

if `which exiftool`.strip.empty?
  puts "please install exiftool for your system."
  exit
end

module Photor
  class Exif
    def initialize(path)
      @data = JSON.parse(`exiftool #{path} -json`).first
    end

    def date_time
      self.class.exif_time(@data['DateTimeOriginal'])
    end

    def [](name)
      @data[name]
    end

    def method_missing(name, *args)
      if @data.key? name
        # if we need it once, we'll likely need it again.
        define_method(name) { @data[name] }
        send name
      else
        super
      end
    end

    def self.exif_time(str)
      return nil if str.nil? or str.empty?
      t = Time.parse(str) rescue nil
      t ||= if md = str.match(/^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d):(\d\d)$/)
        Time.mktime($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i) rescue nil
      end
      t || raise("unknown time format: #{str}")
    end
  end
end
