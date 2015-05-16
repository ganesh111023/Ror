class Comment < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  validates :body, presence: true, length: { maximum: 1000 }
  def self.per_page
    10
  end
end
