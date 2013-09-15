require_relative 'test_helper'

class PhotorTest < MiniTest::Unit::TestCase
  include PhotorTestHelper

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
end
