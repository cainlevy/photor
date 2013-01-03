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

      d_path = ::File.join(destination, Photor.path(jpg.taken_at, jpg.name))
      if options[:dry_run]
        puts "moving #{jpg.path} to #{d_path}"
      else
        FileUtils.mkdir_p ::File.dirname(d_path)
        FileUtils.mv jpg.path, d_path
      end
    end
    puts "\n"
  end

end
