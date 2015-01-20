require 'aws'
AWS.config(s3_cache_object_attributes: true)
ENV['AWS_PROFILE'] ||= 'photor'
