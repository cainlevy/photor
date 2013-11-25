require 'thor'

class Photor::CLI < Thor

  desc "organize [SOURCE] [DESTINATION]",
    "moves photos from SOURCE to DESTINATION by date"
  long_desc <<-DESC
    Recursively searches the SOURCE directory and all sub-directories for JPEGs.
    Moves each found JPEG into a date hierarchy in DESTINATION.
  DESC
  method_option :dry_run, :type => :boolean, :desc => "report actions that would be taken without performing them"
  def organize(source, destination)
    Photor.each_jpeg(source) do |jpg|
      print "."

      s_path = File.expand_path(jpg.path)
      d_path = File.expand_path(File.join(destination, Photor.path(jpg.taken_at, jpg.name)))
      next if s_path == d_path

      if options[:dry_run]
        puts "\nmoving #{s_path} to #{d_path}"
      else
        FileUtils.mkdir_p File.dirname(d_path)
        FileUtils.mv s_path, d_path
      end
    end
    puts "\n"
  end

end
