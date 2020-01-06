module Photor
  class Media
    attr_reader :path

    def self.find(path)
      if File.exists?(path)
        new(path)
      else
        nil
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

    def taken_at
      time_from_name || raise(Photor::TimeFormatError, name)
    end

    def time_from_name
      md = name.match(/
        (\A|[^\d])
        (?<yr>\d{4})
        [^\d]?
        (?<mon>\d{2})
        [^\d]?
        (?<day>\d{2})
        [^\d]?
        (?<hr>\d{2})
        [^\d]?
        (?<min>\d{2})
        [^\d]?
        (?<sec>\d{2})
        [^\d]
      /x)

      md && Time.parse("#{md[:yr]}#{md[:mon]}#{md[:day]} #{md[:hr]}#{md[:min]}#{md[:sec]}")
    rescue ArgumentError
      nil
    end
  end
end
