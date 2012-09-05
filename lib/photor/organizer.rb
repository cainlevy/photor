module Photor
  class Organizer
    def initialize(source, destination)
      @source = source
      @destination = destination
    end

    def run(options = {})
      puts "scanning:"
      Photor.each_jpeg(@source) do |jpg|
        print "."

        d_path = File.join(@destination, jpg.to_path)

        if File.exists? d_path
          existing = Photor::JPEG.new(d_path)
          if jpg == existing
            puts "#{d_path} exists" if options[:dry_run]
            next
          else
            i = 0
            while File.exists? d_path
              i += 1
              d_path = d_path.sub(/\.([a-z]*$)/, ".#{i}.\\1")
            end
          end
        end

        if options[:dry_run]
          puts "mkdir -p #{File.dirname(d_path)}"
          puts "cp #{jpg.path} #{d_path}"
        else
          FileUtils.mkdir_p(File.dirname(d_path))
          FileUtils.cp jpg.path, d_path
        end
      end
      puts "\n"
    end
  end
end