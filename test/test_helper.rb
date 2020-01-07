require 'rubygems'
require 'minitest/autorun'

require_relative '../lib/photor'

require 'tmpdir'
require 'fileutils'
module PhotorFixturesHelper
  FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')
  IMAGE = File.join(FIXTURES_PATH, 'blank_pixel.jpg')
  MOVIE = File.join(FIXTURES_PATH, 'sample.mp4')

  # creates a fixture image
  # optionally with specified exif values
  def img(path, exifs = {})
    mkdir(path)
    File.join(photos_path, path).tap do |destination|
      FileUtils.cp(IMAGE, destination)

      if exifs.any?
        `exiftool -overwrite_original -preserve -n #{exifs.map{|k, v| "-#{k}=#{Photor.shellarg(v)}" }.join(' ')} #{Photor.shellarg(destination)}`
      end
    end
  end

  def mov(path)
    mkdir(path)
    File.join(photos_path, path).tap do |destination|
      FileUtils.cp(MOVIE, destination)
    end
  end

  def mkdir(path)
    if path.include?('/')
      FileUtils.mkdir_p(File.join(photos_path, File.dirname(path)))
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
