require 'thor'
require_relative '../db/photos'
require_relative '../db/tags'

class Photor::CLI < Thor

  desc "", ""
  long_desc ""
  method_option :dir, :type => :string, :default => '.', :desc => "location of photos and sqlite3 db"
  def site
    db = Photor::DB.new(options[:dir])
    Photor::Site.new(db, options[:dir]).generate
  end

end

require 'erb'
require 'date'
require 'fileutils'

module Photor
  class Site < Struct.new(:db, :dir)
    VIEWDIR = File.join(File.dirname(__FILE__), '../../../views')

    def generate
      generate_root
      generate_years
      generate_tags
      copy_assets
    end

    protected

    def generate_root
      create '/index.html', Page.new(title: 'Photor Site') do
        render('albums', title: 'Years', albums: db.photos.years.map{|year| Album.new(name: year, path: year_index(year)) }) +
        render('albums', title: 'Tags', albums: db.tags.all.map{|t| Album.new(name: t.name, path: tag_path(t)) })
      end
    end

    def generate_years
      db.photos.years.each do |year|
        create year_index(year), Page.new(title: year) do
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
        create tag_index(tag), Page.new(title: tag.name) do
          render('photos', photos: tag.photos)
        end
      end
    end

    def copy_assets
      Dir[File.join(VIEWDIR, '*.{css,js}')].each do |path|
        FileUtils.copy(path, File.join(dir, File.basename(path)))
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

    module Routes
      module_function

      def photo_path(photo)
        "/#{Photor.path(photo.taken_at, photo.filename.sub(/\.[a-z]*/, '.html'))}"
      end

      def tag_path(tag)
        "/t/#{tag.name}"
      end

      def tag_index(tag)
        File.join(tag_path(tag), 'index.html')
      end

      def year_index(year)
        "/#{year}/index.html"
      end
    end
    include Routes

    module Views
      module_function

      def create(path, page, &block)
        path = File.join(dir, path)
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
    include Views

    class ERBBinding
      include Routes
      include Views

      def initialize(args = {})
        args.each do |k, v|
          define_singleton_method(k){ v }
        end
      end

      def binding
        super
      end
    end
  end
end
