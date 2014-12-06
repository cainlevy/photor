require 'thor'
require 'aws'
AWS.config(s3_cache_object_attributes: true)
ENV['AWS_PROFILE'] ||= 'photor'

class Photor::CLI < Thor

  desc "s3push [LIBRARY] [BUCKET]",
    "pushes the organized LIBRARY up to a BUCKET in Amazon's S3"
  long_desc <<-DESC
    Compares all JPEGs in LIBRARY against BUCKET on Amazon S3, and uploads files that are new or changed.

    Does not pull unknown files from S3.

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
      # convert date str to time
      since = Date.new(*options[:since].split('-').map(&:to_i)).to_time
    end

    puts "scanning photos #{"since #{since}" if since}:"
    Photor.each_jpeg(library, since: since).with_index do |jpg, idx|
      print '.'
      library_path = jpg.path.sub(/^#{library}\//, '')
      s3_object = bucket.objects[library_path]

      if s3_object.exists?
        s3_etag = s3_object.etag.gsub(/"/, '') # why the quotes?
        next if s3_etag == jpg.md5
      end

      if options[:dry_run]
        puts "uploading #{library_path}"
      else
        # Naive upload. Might be nice to upload via background queue, with progress bars.
        s3_object.write(Pathname.new(library_path))
      end
    end
  end
end
