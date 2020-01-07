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

  def self.each_jpeg(dir, since: nil, &block)
    each_file(dir, since: since, extensions: %w[jpg jpeg], &block)
  end

  def self.each_file(dir, since: nil, extensions: %w[jpg jpeg mp4 mov])
    return to_enum(:each_file, dir, since: since, extensions: extensions) unless block_given?

    Dir.glob(File.join(dir, '**', "*.{#{extensions.join(',')}}"), File::FNM_CASEFOLD).each do |o_path|
      media = Photor::Media.from(o_path)
      next if since && media.mtime < since

      yield media
    end
  end

  def self.path(taken_at, name)
    "#{taken_at.strftime "%Y/%m/%d"}/#{name}"
  end

  def self.shellarg(val)
    Shellwords.escape(val)
  end
end
