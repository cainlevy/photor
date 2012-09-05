#!/usr/bin/env ruby

require_relative '../lib/photor'

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: photor.rb [options] --ACTION $arg1 ..."

  opts.on '-o', '--organize', 'Organize from <source> to <destination>' do
    unless ARGV[0]
      puts "please specify the source directory"
      exit
    end
    unless ARGV[1]
      puts "please specify the destination directory"
      exit
    end

    options[:action] = Photor::Organizer.new(ARGV[0], ARGV[1])
  end

  options[:dry_run] = false
  opts.on '-d', '--dry-run', "Print actions instead of running them" do
    options[:dry_run] = true
  end

  opts.on '-h', '--help', 'Display this help' do
    puts opts
    exit
  end
end.parse!

if options[:action]
  options[:action].run(options)
else
  puts "please specify an action"
end