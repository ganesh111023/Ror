class News < ActiveRecord::Base
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
end
