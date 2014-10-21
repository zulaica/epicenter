class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :payment_method, polymorphic: true

  validates_presence_of :amount, :user_id
  validates :payment_method, presence: true

  before_create :make_payment

private
  def make_payment
    payment_method_to_charge = user.primary_payment_method
    self.amount = payment_method_to_charge.calculate_charge(amount)
    begin
      debit = payment_method_to_charge.fetch_balanced_account.debit(
        :amount => amount,
        :appears_on_statement_as => 'Epicodus tuition'
      )
      self.payment_uri = debit.href
    rescue => exception
      errors.add(:base, exception.description)
      false
    end
  end
end
