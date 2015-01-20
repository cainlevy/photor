require 'thor'
require_relative '../actors'
require_relative '../aws'

class Photor::CLI < Thor
  class Uploader < Struct.new(:library, :bucket, :dry_run)
    include Celluloid

    def upload_if_new(jpg)
      library_path = jpg.path.sub(/^#{library}\//, '')

      if is_new?(library_path, jpg.md5)
        if dry_run
          puts "uploading #{library_path}"
        else
          upload(library_path)
        end
        print '+'
        true
      else
        print '.'
        false
      end
    end

    protected

    def is_new?(library_path, md5)
      s3_object = bucket.objects[library_path]
      !(s3_object.exists? && etag(s3_object) == md5)
    end

    def upload(library_path)
      bucket.objects[library_path].write(Pathname.new(library_path))
    end

    def etag(s3_object)
      s3_object.head[:etag].gsub(/"/, '') # why the quotes?
    end
  end

  desc "s3push [LIBRARY] [BUCKET]",
    "pushes the organized LIBRARY up to a BUCKET in Amazon's S3"
  long_desc <<-DESC
    Compares all JPEGs in LIBRARY against BUCKET on Amazon S3, and uploads files that are new or changed.

    Does not download files from S3. Use `s3pull` instead.

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
  method_option :since, type: :string, desc: 'only compare files modified since date YYYY-MM-DD'
  def s3push(library, s3_bucket_name)
    s3 = AWS::S3.new
    bucket = s3.buckets[s3_bucket_name]

    if options[:since]
      since = Date.new(*options[:since].split('-').map(&:to_i)).to_time
    end

    puts "scanning photos #{"since #{since}" if since}:"
    stats = Photor.work(Uploader.pool(args: [library, bucket, options[:dry_run]])) do |pool, &tracker|
      Photor.each_jpeg(library, since: since) do |jpg|
        tracker.call pool.upload_if_new(jpg)
      end
    end

    puts "\n"
    puts "uploaded: #{stats[:truthy]} skipped: #{stats[:falsey]}"
  end
end
