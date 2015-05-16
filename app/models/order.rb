class Order < ActiveRecord::Base
  extend Enumerize

  belongs_to  :user
  belongs_to  :checkout_country, :foreign_key => 'country_code'
  has_many    :order_items, :dependent => :destroy
  has_many    :transactions, :class_name => 'OrderTransaction'

  STATUS_IN_PROGRESS   = 1
  STATUS_COMPLETED     = 2
  STATUS_CANCELED      = 3

  monetize :amount_cents
  enumerize :status, in: {in_progress: STATUS_IN_PROGRESS, completed: STATUS_COMPLETED, canceled: STATUS_CANCELED}, scope: :having_status

  validate :validate_card, :on => :create,
           unless: Proc.new { |a| a.card_type == 'paypal' }

  validates :address1, presence: true, unless: Proc.new { |order| order.address2.present? }
  validates :address2, presence: true, unless: Proc.new { |order| order.address1.present? }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :city, presence: true
  validates :phone, presence: true

  attr_accessor :card_number, :card_verification

  def purchase(cart)
    price = price_cents(cart)
    status = STATUS_CANCELED

    ActiveMerchant::Billing::Base.mode = :test
    gateway = ActiveMerchant::Billing::PaypalGateway.new(
        :login => "imshenitsky-facilitator_api1.gmail.com",
        :password => "B493YU2FXLXCSS3K",
        :signature => "AFcWxV21C7fd0v3bYYYRCpSSRl31As05yompeWaapIS7ul6kAQc9lgwv"
    )

    response = gateway.purchase(price, credit_card, purchase_options)
    status = STATUS_COMPLETED if response.success?
    transactions.create!(:action => "purchase", :amount => price, :response => response)
    self.update_attributes(:updated_at => Time.now, :status => status)
    response.success?
  end

  private

  def price_cents(cart)
    cart.total
  end

  def purchase_options
    {
        :ip => ip_address,
=begin
        :billing_address => {
            :name     => "Ryan Bates",
            :address1 => "123 Main St.",
            :city     => "New York",
            :state    => "NY",
            :country  => "US",
            :zip      => "10001"
        }
=end
    }
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors[:base] << message
      end
    end
  end


  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
        :type               => card_type,
        :number             => card_number,
        :verification_value => card_verification,
        :month              => card_expires_on.month,
        :year               => card_expires_on.year,
        :first_name         => first_name,
        :last_name          => last_name
    )
  end

end
