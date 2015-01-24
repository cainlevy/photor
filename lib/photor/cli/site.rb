require 'thor'

class Photor::CLI < Thor

  desc "", ""
  long_desc ""
  method_option :dir, :type => :string, :default => '.', :desc => "location of photos and sqlite3 db"
  def site
    db = Photor::DB.new(options[:dir])
    puts Photor::Site.new(db).generate
  end

end

require 'erb'

module Photor
  class Site < Struct.new(:db)
    VIEWDIR = File.join(File.dirname(__FILE__), '../../../views')

    def generate
      generate_years
    end

    protected

    def generate_years
      render 'albums', albums: db.photos.years.map{|year| Album.new(name: year) }
    end

    class Album
      attr_accessor :name
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

    def render(name, kwargs)
      in_layout{ template(name).result(ERBBinding.new(kwargs).binding) }
    end

    def in_layout(name = 'layout', &block)
      template('layout').result(ERBBinding.new(page: Page.new(title: 'Hello World')).binding(&block))
    end

    def template(name)
      ERB.new(File.read(File.join(VIEWDIR, name + '.html.erb')), nil, '<>')
    end
  end
end
