module Photor
  class File
    attr_reader :path

    def initialize(path)
      @path = path

      extend(Photor::JPEG) if path =~ /[.]jpe?g\Z/i
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
      Photor.path(taken_at, name)
    end

    def ==(other)
      self.size == other.size && self.md5 == other.md5
    end
  end
end
