require_relative 'test_helper'

class PhotorTest < MiniTest::Test
  include PhotorFixturesHelper

  def test_method_each_jpeg
    expected = []
    expected << img('foo.jpg')
    expected << img('a/bar.jpeg')
    expected << img('a/b/baz.JPG')
    expected << img('a/b/c/qux.JPEG')
    img('foo.gif')
    img('foo.png')

    jpgs = Photor.each_jpeg(photos_path).to_a
    assert_equal expected.sort, jpgs.map(&:path).sort
  end

  def test_each_jpeg_since
    # set mtime to 2014-10-30 12:34:00
    older = img('older.jpg').tap{|path| `touch -t201410301234 #{path}` }
    newer = img('newer.jpg')

    jpgs = Photor.each_jpeg(photos_path, since: '2014-11-01').to_a
    assert_equal [newer], jpgs.map(&:path).sort

    jpgs = Photor.each_jpeg(photos_path, since: '2014-01-01').to_a
    assert_equal [older, newer].sort, jpgs.map(&:path).sort

    jpgs = Photor.each_jpeg(photos_path, since: '2014-10-30').to_a
    assert_equal [older, newer].sort, jpgs.map(&:path).sort
  end
end

class Photor::ExifTest < MiniTest::Unit::TestCase
  include PhotorFixturesHelper

  def test_array_accessors
    path = img("1.jpg", 'Description' => 'Foo')
    data = Photor::Exif.new(path)
    assert_equal 'Foo', data['Description']
    data['Description'] = 'Bar'
    data = Photor::Exif.new(path)
    assert_equal 'Bar', data['Description']
  end

  def test_date_time
    # TODO: more formats?
    ['2011:05:01 20:01:23'].each.with_index do |t, i|
      path = img("#{i}.jpg", 'DateTimeOriginal' => t)

      data = Photor::Exif.new(path)
      # fun: exif times may have different formats
      # the ones i've seen don't have time zones
      # ideally the system's offset matches the camera's offset
      assert_equal '2011-05-01 20:01:23', data.date_time.strftime('%F %T')
    end
  end
end
