class Country < ActiveRecord::Base
  self.primary_key = 'code'

  has_and_belongs_to_many :products, :foreign_key => 'country_code'
  has_many :categories, :foreign_key => 'country_code'

  def self.by_locale(locale)
    find(locale)
  end
end