class Category < ActiveRecord::Base
  include TheSortableTree::Scopes
  acts_as_nested_set
  has_many :products
  belongs_to :country, :foreign_key => 'country_code'

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history]

  validates :name, presence: true, length: { maximum: 255 }
  validates :country, presence: true

  def slug_candidates
    [
        :name,
        [:name, :country_code]
    ]
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def normalize_friendly_id(text)
    text.to_slug.normalize! :transliterations => [:russian, :latin]
  end

  def self.for_tree(country_code, gift = 0)
    nested_set.select('id, name, slug, parent_id, depth').where(:country_code => country_code, :is_gift => gift)
  end

end
