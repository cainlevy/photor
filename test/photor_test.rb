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

    jpgs = Photor.each_jpeg(photos_path, since: Time.parse('2014-11-01')).to_a
    assert_equal [newer], jpgs.map(&:path).sort

    jpgs = Photor.each_jpeg(photos_path, since: Time.parse('2014-01-01')).to_a
    assert_equal [older, newer].sort, jpgs.map(&:path).sort

    jpgs = Photor.each_jpeg(photos_path, since: Time.parse('2014-10-30')).to_a
    assert_equal [older, newer].sort, jpgs.map(&:path).sort
  end
end

class Photor::ExifTest < Minitest::Test
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

class Photor::MediaTest < Minitest::Test
  def test_time_from_name
    [
      '2020-01-01_12-34-56.jpg',
      '20200101_123456.jpg',
      '20200101123456.jpg',
      'img_20200101_123456-o.jpg'
    ].each do |name|
      media = Photor::Media.new(name)
      assert_equal Time.parse('2020-01-01 12:34:56'), media.taken_at
    end

    [
      '99999999_999999.jpg'
    ].each do |name|
      begin
        Photor::Media.new(name).taken_at
        refute true
      rescue Photor::TimeFormatError
        assert true
      end
    end
  end
end
