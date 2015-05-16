class Feedback < ActiveRecord::Base
  extend Enumerize

  def self.per_page
    5
  end

  model_name.instance_variable_set(:@route_key, 'feedback')
  self.table_name = 'feedback'

  enumerize :reason, in: [:TEHNICAL,:PAYMENT, :PROGRAMM, :QUALITY, :OTHER], default: :PROGRAMM
  enumerize :contact_type, in: [:EMAIL,:SKYPE,:PHONE]

  validates :contact, presence: true, length: { maximum: 45 }
  validates :comment, presence: true, length: { maximum: 65535 }
  validates :name, presence: false, length: { maximum: 45 }


end