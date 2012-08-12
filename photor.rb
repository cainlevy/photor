#!/usr/bin/env ruby

require 'fileutils'
require 'digest'
require 'rubygems'

$: << File.join(File.dirname(__FILE__), 'lib')
require 'photor/photo'
require 'photor/jpeg'

unless origin = ARGV[0]
  puts "please specify the origin directory"
  exit
end
target = ARGV[1] || "~/Pictures"
dryrun = true

puts "scanning:"
Dir.glob(File.join(origin, '**', '*.{jpg,jpeg,JPG,JPEG}')).each do |o_path|
  print "."

  jpg = Photor::JPEG.new(o_path)
  t_path = File.join(target, jpg.to_path)

  if File.exists? t_path
    existing = Photor::JPEG.new(t_path)
    if jpg == existing
      puts "#{t_path} exists" if dryrun
      next
    else
      i = 0
      while File.exists? t_path
        i += 1
        t_path = t_path.sub(/\.([a-z]*$)/, ".#{i}.\\1")
      end
    end
  end

  if dryrun
    puts "mkdir -p #{File.dirname(t_path)}"
    puts "cp #{o_path} #{t_path}"
  else
    FileUtils.mkdir_p(File.dirname(t_path))
    FileUtils.cp o_path, t_path
  end
end
puts "\n"
