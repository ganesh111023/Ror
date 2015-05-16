class Product < ActiveRecord::Base
  extend Enumerize
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history]

  ratyrate_rateable 'rating'

  STATUS_ACTIVE   = 1
  STATUS_EDIT     = 2
  STATUS_DELETED  = 3

  belongs_to :category
  belongs_to :vendor
  has_one  :primary_image, -> { where(is_primary: true) }, :class_name => 'Image'
  has_many :images, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_one :rating, :dependent => :destroy, :class_name => 'RatingCache', :foreign_key => 'cacheable_id'
  has_and_belongs_to_many :countries, :association_foreign_key => 'country_code'

  accepts_nested_attributes_for :images

  scope :featured, -> { where(is_featured: true) }

  validates :name, presence: true, length: { maximum: 255 }
  validates :category, presence: true
  validates :countries, presence: true

  monetize :price_cents, :as => 'vendor_price'
  enumerize :status, in: {active: STATUS_ACTIVE, edit: STATUS_EDIT, deleted: STATUS_DELETED}, scope: :having_status

  before_save :before_save_process

  # --------------------
  # friendly_id methods
  # --------------------
  def slug_candidates
    [
        [:name, :model],
        [:name, :model, :category_id],
    ]
  end

  # Route helpers will then use the numeric id rather than the slug.
  def to_param
    id.to_s
  end

  def should_generate_new_friendly_id?
    name_changed? || model_changed?
  end

  def normalize_friendly_id(text)
    text.to_slug.normalize! :transliterations => [:russian, :latin]
  end

  #
  # Other methods
  #
  def price
    if vendor
      ((self.vendor_price * self.vendor.markup_percent) / 100) + self.vendor_price
    else
      self.vendor_price
    end
  end

  def self.search(search, page, per_page  = 3)
    t = Product.arel_table
    having_status(:active).order(:price_cents).where(t[:searchable].matches("%#{search}%"))
        .paginate :page => page, :per_page => per_page
  end

  def title
    "#{self.name} #{self.model}"
  end

  def self.import(file, opts)
    inserts             = []
    header              = []
    rows_examined       = 0
    h                   = {:new_products => 0, :updated_products => 0, :new_categories => 1, :updated_categories => 0}
    title_pattern       = ['title','наименование','item','продукт']
    price_pattern       = ['price','цена','цена usd','usd']
    model_pattern       = ['модель','model']
    description_pattern = ['описание','description','remarks']
    quantity_pattern    = ['quantity','количество','к-во']
    input_currency      = opts[:input_currency]
    status              = Product::STATUS_EDIT

    # Temporary. Waiting for new Roo release
    spreadsheet =
      if opts.include?(:url)
        Roo::Spreadsheet.open(opts[:url], opts)
      else
        open_spreadsheet(file)
      end

    country = Country.by_locale(opts[:locale])

    #s = '/Users/nikolay/Desktop/import/WattПрайс22012015.xls'
    #s = '/Users/nikolay/Desktop/import/MPMprice2014_short.xls'
    #spreadsheet = Roo::Excel.new(s, nil, :ignore)

    # Initialize bank for currency exchange
    default_curr   = Money.default_currency.iso_code
    bank           = Money.default_bank
    rate = bank.get_rate(input_currency, default_curr).to_f

    # Category (default): storage for products if spreadsheet doesn't contain categories
    t      = Time.now
    @cat   = Category.create!(:name => 'Import ' + t.to_s(:long), :country_code => country)
    def_id = @cat.id

    if opts[:import_type] == ImportTask::TYPE_SYNC
      Product.where(vendor: opts[:vendor_id]).update_all(status: Product::STATUS_DELETED)
    elsif opts[:import_type] == ImportTask::TYPE_NEW
      status = Product::STATUS_ACTIVE
    end

    spreadsheet.each_with_pagename do |name, sheet|
      sheet.each do |row|

        rows_examined += 1
        next if row[0].nil?

        # Header: :title, :price are required
        if header.blank?
          row.map do |v|
            v = :title if title_pattern.include?(v.to_s.mb_chars.downcase)
            v = :price if price_pattern.include?(v.to_s.mb_chars.downcase)
            v = :model if model_pattern.include?(v.to_s.mb_chars.downcase)
            v = :quantity if quantity_pattern.include?(v.to_s.mb_chars.downcase)
            v = :description if description_pattern.include?(v.to_s.mb_chars.downcase)
            header << v
          end

          header = [] if !header.include?(:title) || !header.include?(:price)
          raise 'Данный файл не содержит необходимых заголовков. Для названия продукта это: ' + title_pattern.join(', ') if rows_examined >= 20
          next
        end

        transposed = Hash[[header, row].transpose]

        # Category: the row should contain one non-empty string and the rest should be empty, nil, or 0
        cat_data = transposed.reject { |k,v| v.is_a?(Numeric) ? v == 0 : v.to_s.empty? }
        cat_name = cat_data.values.first if cat_data.length == 1

        if cat_name
          cat_name.strip!
          cat_name_copy = cat_name.mb_chars.downcase.capitalize # doesn't change original, make a copy

          @cat = Category.find_by(name: cat_name_copy, country_code: country, is_gift: 0)
          if @cat.blank?
            @cat = Category.create!(:name => cat_name_copy, :country_code => country)
            @cat.reload
            h[:new_categories] += 1
          end
          next
        end

        # Product:
        pattern = '^A-Za-zА-Яа-я0-9, - \\.'
        name = transposed[:title].to_s
        name.tr!(pattern, '')
        name.strip!

        desc = transposed[:description].to_s
        desc.tr!(pattern, ', ')
        desc.strip!

        model = transposed[:model].to_s
        model.tr!(pattern, '')
        model.strip!

        searchable = "#{name} #{model}"

        original_price  = transposed[:price].to_f
        next if original_price <= 0

        price           = original_price.to_money # Money object
        price           = bank.exchange_with(Money.new(price.cents, input_currency), default_curr) unless input_currency == default_curr

        p = country.products.find_by(name: name, model: model, vendor: opts[:vendor_id]) # category: @cat.id,
        if p.blank?
          product_params = {
              name:               name,
              description:        desc,
              model:              model,
              searchable:         searchable,
              price_cents:        price.cents,
              category_id:        @cat.id,
              original_price:     original_price,
              original_currency:  input_currency,
              exch_rate:          rate,
              quantity:           transposed[:quantity].to_i,
              vendor_id:          opts[:vendor_id],
              status:             status,
              country_ids:        [opts[:locale]]
          }
          Product.create product_params
          h[:new_products] += 1
        else
          p.vendor_price  = transposed[:price]
          p.updated_at    = t.to_s(:db)
          p.quantity      = transposed[:quantity].to_i
          p.status        = status
          p.save
          h[:updated_products] += 1
        end
      end

      # Delete default category because the imported document has its own categories
      unless def_id == @cat.id
        Category.find(def_id).destroy
        h[:new_categories] -= 1
      end

      return h
    end
  end

  def self.category(h)
    h.each do |k, v|
      puts "#{v},  #{v.class}"
    end
  end

  def self.open_spreadsheet(file)
    raise 'Выберите файл .xls, .xlsx' if file.blank?
    case File.extname(file.original_filename)
      when ".csv"  then Roo::Csv.new(file.path, nil, :ignore)
      when ".xls"  then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Неизвестный тип файла: #{file.original_filename}"
    end
  end

  private

  def before_save_process
    self.searchable  = "#{self.name} #{self.model} #{self.description}"
  end

end
