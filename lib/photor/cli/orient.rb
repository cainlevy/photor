require 'thor'

class Photor::CLI < Thor

  desc "orient [FOLDER]",
    "auto-orients photos in FOLDER"
  long_desc <<-DESC
    Finds JPEGs in FOLDER where the Orientation is not 1, and rotates them. Sets
    Orientation=1 when it is finished.
  DESC
  def orient(folder)
    orientations = {
      2 => '-flip horizontal',
      3 => '-rotate 180',
      4 => '-flip vertical',
      5 => '-transpose',
      6 => '-rotate 90',
      7 => '-transverse',
      8 => '-rotate 270'
    }

    ct = 0
    puts "scanning:"
    Photor.each_jpeg(folder) do |jpg|
      print "."
      next unless transform = orientations[jpg.orientation]

      # losslessly transform
      `jpegtran -copy all -perfect #{transform} #{Photor.shellarg jpg.path} > #{$$}.tmp`

      if $?.exitstatus == 0
        `mv #{$$}.tmp #{Photor.shellarg jpg.path}`
        jpg.exif['Orientation'] = 1
        ct += 1
      else
        `rm #{$$}.tmp`
        puts "could not orient #{jpg.path}"
      end
    end
    puts "\n"
    puts "oriented: #{ct}"
  end

end
