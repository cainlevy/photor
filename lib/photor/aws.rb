require 'aws-sdk-s3'
Aws.config.update(s3_cache_object_attributes: true)
ENV['AWS_PROFILE'] ||= 'photor'
