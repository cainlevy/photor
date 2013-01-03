require 'fileutils'
require 'digest'

require_relative 'photor/file'

module Photor
  def self.each_jpeg(dir, &block)
    Dir.glob(File.join(dir, '**', '*.{jpg,jpeg,JPG,JPEG}')).each do |o_path|
      yield Photor::File.new(o_path)
    end
  end

  def self.path(taken_at, name)
    "#{taken_at.strftime "%Y/%m/%d"}/#{name}"
  end

  def self.shellarg(val)
    "\"#{val.gsub(/"/){|m| "\\" + m}}\""
  end
end
