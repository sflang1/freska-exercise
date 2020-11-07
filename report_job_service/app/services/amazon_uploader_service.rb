require 'aws-sdk-s3'

class AmazonUploaderService < ApplicationService
  attr_reader :file_paths

  def initialize(file_paths)
    @file_paths = file_paths
  end

  def call
    resource = Aws::S3::Resource.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_ID_KEY']
    )
    @file_paths.each do |filename|
      last_position = filename.rindex('/')
      object_name = filename[last_position+1..-1]
      object = resource.bucket(ENV['AWS_BUCKET_NAME']).object(object_name)
      object.upload_file(filename)
    end
  end
end