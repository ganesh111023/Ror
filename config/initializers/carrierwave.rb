CarrierWave.configure do |config|
  config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     'AKIAI7KUUZ7SKJ5YMLZQ',
      aws_secret_access_key: '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',
      region:                'us-west-2',                  # optional, defaults to 'us-east-1'
      #host:                  's3.example.com',             # optional, defaults to nil
      #endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = 'step2soft-depot'                          # required
  config.fog_public     = false                                        # optional, defaults to true
  config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}
end