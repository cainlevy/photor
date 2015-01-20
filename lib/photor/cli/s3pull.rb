require 'thor'
require_relative '../actors'
require_relative '../aws'

class Photor::CLI < Thor
  class Downloader < Struct.new(:library, :dry_run)
    include Celluloid

    def fetch_if_new(s3_object)
      local_path = File.join(library, s3_object.key)
      etag       = s3_object.etag.gsub(/"/, '') # why the quotes?

      if is_new?(local_path, etag)
        if dry_run
          puts "downloading #{s3_object.key}"
        else
          fetch(s3_object, local_path)
        end
        print '+'
        true
      else
        print '.'
        false
      end
    end

    protected

    def is_new?(local_path, etag)
      jpg = Photor::JPEG.find(local_path)
      jpg.nil? || jpg.md5 != etag
    end

    def fetch(s3_object, local_path)
      FileUtils.mkdir_p(File.dirname(local_path))
      File.open(local_path, 'wb') do |f|
        s3_object.read{ |chunk| f.write chunk }
      end
    end
  end

  desc "s3pull [BUCKET] [LIBRARY]",
    "pulls an Amazon S3 BUCKET into a local LIBRARY"
  long_desc <<-DESC
    Compares all JPEGs in BUCKET on Amazon S3 against the local LIBRARY, and downloads files that are new or changed.

    Does not upload files to S3. Use `s3push` instead.

    Does not delete files remotely or locally.

    Amazon S3 credentials can be configured using any of the options on http://docs.aws.amazon.com/AWSSdkDocsRuby/latest/DeveloperGuide/set-up-creds.html. Examples:

      1) a `photor' profile in your ~/.aws/credentials, e.g.:

        [photor]
        aws_access_key_id = <your access key>
        aws_secret_access_key = <your secret key>

      2) exported ENV vars

        export AWS_ACCESS_KEY_ID=<your access key>
        export AWS_SECRET_ACCESS_KEY=<your secret key>

      3) an IAM role on your EC2 instance
  DESC
  method_option :dry_run, type: :boolean, desc: 'report actions that would be taken without performing them'
  # TODO: option to only sync certain files. maybe by tag? maybe by subfolder (datepart)?
  def s3pull(s3_bucket_name, library)
    s3 = AWS::S3.new
    bucket = s3.buckets[s3_bucket_name]

    stats = Photor.work(Downloader.pool(args: [library, options[:dry_run]])) do |pool, &tracker|
      bucket.objects.each do |s3_object|
        next if File.extname(s3_object.key).empty?
        tracker.call pool.fetch_if_new(s3_object)
      end
    end

    puts "\n"
    puts "downloaded: #{stats[:truthy]} skipped: #{stats[:falsey]}"
  end
end
