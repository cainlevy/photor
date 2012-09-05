module Photor
  class Organizer
    def initialize(source, destination)
      @source = source
      @destination = destination
    end

    def run(options = {})
      puts "scanning:"
      Dir.glob(File.join(@source, '**', '*.{jpg,jpeg,JPG,JPEG}')).each do |o_path|
        print "."

        jpg = Photor::JPEG.new(o_path)
        t_path = File.join(@destination, jpg.to_path)

        if File.exists? t_path
          existing = Photor::JPEG.new(t_path)
          if jpg == existing
            puts "#{t_path} exists" if options[:dry_run]
            next
          else
            i = 0
            while File.exists? t_path
              i += 1
              t_path = t_path.sub(/\.([a-z]*$)/, ".#{i}.\\1")
            end
          end
        end

        if options[:dry_run]
          puts "mkdir -p #{File.dirname(t_path)}"
          puts "cp #{o_path} #{t_path}"
        else
          FileUtils.mkdir_p(File.dirname(t_path))
          FileUtils.cp o_path, t_path
        end
      end
      puts "\n"
    end
  end
end