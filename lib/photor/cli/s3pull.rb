require 'thor'
require 'aws'
AWS.config(s3_cache_object_attributes: true)
ENV['AWS_PROFILE'] ||= 'photor'

class Photor::CLI < Thor

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
    downloaded = 0
    skipped = 0

    if options[:since]
      since = Date.new(*options[:since].split('-').map(&:to_i)).to_time
    end

    bucket.objects.each do |s3_object|
      next if File.extname(s3_object.key).empty?
      print '.'
      local_path = File.join(library, s3_object.key)
      s3_etag = s3_object.etag.gsub(/"/, '') # why the quotes?
      if jpg = Photor::JPEG.find(local_path)
        if jpg.md5 == s3_etag
          skipped += 1
          next
        end
      end
      downloaded += 1

      if options[:dry_run]
        puts "downloading #{s3_object.key}"
      else
        # TODO: download in threaded queue, with progress bars
        FileUtils.mkdir_p(File.dirname(local_path))
        File.open(local_path, 'wb') do |f|
          s3_object.read do |chunk|
            f.write(chunk)
          end
        end
      end
    end
    puts "\n"
    puts "downloaded: #{downloaded} skipped: #{skipped}"
  end
end
