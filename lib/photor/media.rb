module Photor
  class Media
    FINGERPRINT_LENGTH = 24

    attr_reader :path

    def self.find(path)
      if File.exists?(path)
        new(path)
      else
        nil
      end
    end

    def self.from(path)
      if %[.jpg .jpeg].include?(File.extname(path).downcase)
        Photor::JPEG.new(path)
      else
        new(path)
      end
    end

    def initialize(path)
      @path = path
    end

    def name
      @name ||= File.basename(path)
    end

    def extension
      @extension ||= File.extname(path)
    end

    def md5
      @md5 ||= Digest::MD5.file(path).to_s
    end

    def size
      @size ||= File.size(path)
    end

    def mtime
      @mtime ||= File.mtime(path)
    end

    def ==(other)
      self.size == other.size && self.md5 == other.md5
    end

    def unique_name
      @unique_name ||= "#{taken_at.strftime "%Y%m%d%H%M%S"}-#{md5[0, FINGERPRINT_LENGTH]}#{extension}"
    end

    def taken_at
      time_from_name
    end

    private def time_from_name
      md = name.match(/
        (\A|[^\d])
        (?<yr>(19|20)\d\d)
        [^\d]?
        (?<mon>[0-1]\d)
        [^\d]?
        (?<day>[0-3]\d)
        [^\d]?
        (?<hr>[0-2]\d)
        [^\d]?
        (?<min>[0-5]\d)
        [^\d]?
        (?<sec>[0-5]\d)
        [^\d]?
      /x)

      md && Time.parse("#{md[:yr]}#{md[:mon]}#{md[:day]} #{md[:hr]}#{md[:min]}#{md[:sec]}")
    rescue ArgumentError
      nil
    end
  end
end
