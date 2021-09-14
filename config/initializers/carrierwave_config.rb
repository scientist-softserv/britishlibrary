require 'carrierwave'

if Site.instance.account.s3_bucket
  CarrierWave.configure do |config|
    # config.fog_provider = 'fog/aws' # we use carrierwave-aws instead of fog now
    # config.fog_credentials = {
    #   provider: 'AWS',
    #   use_iam_profile: true
    # }
    config.storage = :aws
    config.aws_bucket = Site.instance.account.s3_bucket
    config.aws_acl = 'bucket-owner-full-control'
  end
elsif !Site.instance.account.file_acl
  CarrierWave.configure do |config|
    config.permissions = nil
    config.directory_permissions = nil
  end
end
