require 'rubygems'
require 'minitest/autorun'

require_relative '../lib/photor'

require 'tmpdir'
require 'fileutils'
module PhotorTestHelper
  FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')
  BLANK = File.join(FIXTURES_PATH, 'blank_pixel.jpg')

  def img(path)
    if path.include?('/')
      FileUtils.mkdir_p(File.join(photos_path, File.dirname(path)))
    end
    File.join(photos_path, path).tap do |destination|
      FileUtils.cp(BLANK, destination)
    end
  end

  def photos_path
    @photos_path ||= Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry_secure photos_path if photos_path
    super
  end
end
