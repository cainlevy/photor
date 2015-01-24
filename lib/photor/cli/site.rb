require 'thor'
require_relative '../db/photos'
require_relative '../db/tags'

class Photor::CLI < Thor

  desc "", ""
  long_desc ""
  method_option :dir, :type => :string, :default => '.', :desc => "location of photos and sqlite3 db"
  def site
    db = Photor::DB.new(options[:dir])
    Photor::Site.new(db, './_site').generate
  end

end

require 'erb'
require 'date'

module Photor
  class Site < Struct.new(:db, :basedir)
    VIEWDIR = File.join(File.dirname(__FILE__), '../../../views')

    def generate
      generate_root
      generate_years
      generate_tags
    end

    protected

    def generate_root
      create '/index.html', Page.new(title: 'Photor Site') do
        render('albums', title: 'Years', albums: db.photos.years.map{|year| Album.new(name: year, path: "/#{year}") }) +
        render('albums', title: 'Tags', albums: db.tags.all.map{|t| Album.new(name: t.name, path: "/t/#{URI.escape t.name}") })
      end
    end

    def generate_years
      db.photos.years.each do |year|
        create "/#{year}.html", Page.new(title: year) do
          (1..12).map do |month|
            d1 = Date.new(year.to_i, month.to_i, 1)
            d2 = d1.next_month.prev_day
            photos = db.photos.find_in_time_range(d1.to_time, Time.new(d2.year, d2.month, d2.day, 23, 59, 59))
            next unless photos.any?
            render('photos', photos: photos)
          end.join
        end
      end
    end

    def generate_tags
      db.tags.all.each do |tag|
        create "/t/#{tag.name}.html", Page.new(title: tag.name) do
          render('photos', photos: tag.photos)
        end
      end
    end

    class Album
      attr_accessor :name, :path
      def initialize(**hash)
        hash.each{|k, v| send("#{k}=", v) }
      end
    end

    class Page
      attr_accessor :title
      def initialize(**hash)
        hash.each{|k, v| send("#{k}=", v) }
      end
    end

    private

    class ERBBinding
      def initialize(args = {})
        args.each do |k, v|
          define_singleton_method(k){ v }
        end
      end

      def binding
        super
      end
    end

    def create(path, page, &block)
      path = File.join(basedir, path)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f << render('layout', page: page, &block)
      end
    end

    def render(name, kwargs, &block)
      template(name).result(ERBBinding.new(kwargs).binding(&block))
    end

    def template(name)
      ERB.new(File.read(File.join(VIEWDIR, name + '.html.erb')), nil, '<>')
    end
  end
end
