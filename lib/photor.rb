require 'fileutils'
require 'digest'
require 'shellwords'

require_relative 'photor/jpeg'

module Photor
  class TimeFormatError < StandardError
    def initialize(time)
      super "unknown time format: #{time}"
    end
  end

  def self.each_jpeg(dir, options = {}, &block)
    return to_enum(:each_jpeg, dir, options) unless block_given?

    Dir.glob(File.join(dir, '**', '*.{jpg,jpeg,JPG,JPEG}')).each do |o_path|
      jpg = Photor::JPEG.new(o_path)
      yield jpg unless options[:since] && jpg.mtime < options[:since]
    end
  end

  def self.path(taken_at, name)
    "#{taken_at.strftime "%Y/%m/%d"}/#{name}"
  end

  def self.shellarg(val)
    Shellwords.escape(val)
  end
end
