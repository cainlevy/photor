require_relative 'jpeg'

module Photor
  class File
    attr_reader :path

    def initialize(path)
      @path = path

      extend(Photor::JPEG) if path =~ /[.]jpe?g\Z/i
    end

    def name
      @name ||= ::File.basename(path)
    end

    def extension
      @extension ||= ::File.extname(path)
    end

    def md5
      @md5 ||= Digest::MD5.file(path).to_s
    end

    def size
      @size ||= ::File.size(path)
    end

    def ==(other)
      self.size == other.size && self.md5 == other.md5
    end
  end
end
