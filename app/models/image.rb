class Image < ActiveRecord::Base
  mount_uploader :image_filename, ImageUploaderUploader
  # scope :primary, -> { where(:is_primary => true) }
end
