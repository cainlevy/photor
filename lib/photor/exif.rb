require 'json'
require 'time'

if `which exiftool`.strip.empty?
  puts "please install exiftool for your system."
  exit
end

module Photor
  class Exif
    attr_reader :path

    def initialize(path)
      @path = path
      @data = JSON.parse(`exiftool -n -json #{Photor.shellarg(@path)}`).first
    end

    def date_time
      self.class.exif_time(@data['DateTimeOriginal'])
    end

    def [](name)
      @data[name]
    end

    def []=(name, value)
      `exiftool -overwrite_original -preserve -n -#{name}=#{value} #{Photor.shellarg(@path)}`
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
      return nil if str.nil? or str.empty? or str == '0000:00:00 00:00:00'
      t = Time.parse(str) rescue nil
      t ||= if md = str.match(/^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d):(\d\d)$/)
        Time.mktime($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i) rescue nil
      end
      t || raise(Photor::TimeFormatError, str)
    end
  end
end
