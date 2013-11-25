require 'fileutils'
require 'digest'
require 'shellwords'

require_relative 'photor/jpeg'

module Photor
  def self.each_jpeg(dir, &block)
    return to_enum(:each_jpeg, dir) unless block_given?

    Dir.glob(File.join(dir, '**', '*.{jpg,jpeg,JPG,JPEG}')).each do |o_path|
      yield Photor::JPEG.new(o_path)
    end
  end

  def self.path(taken_at, name)
    "#{taken_at.strftime "%Y/%m/%d"}/#{name}"
  end

  def self.shellarg(val)
    Shellwords.escape(val)
  end
end
