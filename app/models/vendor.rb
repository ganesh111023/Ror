class Vendor < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 45 }
  validates :markup_percent, presence: false, :numericality => {}
end
