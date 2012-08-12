module Photor
  class Photo
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def name
      @name ||= File.basename(path)
    end

    def md5
      @md5 ||= Digest::MD5.file(path).to_s
    end

    def size
      @size ||= File.size(path)
    end

    def taken_at
      @taken_at ||= File.ctime(path)
    end

    def to_path
      "#{taken_at.strftime "%Y/%m/%d"}/#{name}"
    end

    def ==(other)
      self.size == other.size && self.md5 == other.md5
    end
  end
end