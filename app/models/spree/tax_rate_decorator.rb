class SpreeAvatax::TaxRateInvalidOperation < StandardError; end

Spree::TaxRate.class_eval do
  validate :avatax_there_can_be_only_one, on: :create

  class << self
    def match(order)
      [avatax_the_one_rate]
    end

    def adjust(order, items)
      # do nothing.  we'll take care of this ourselves at different points via the various hooks we have in place
    end

    # require exactly one tax rate.  if that's not true then alert ourselves and carry on as best we can
    def avatax_the_one_rate
      rates = all.to_a
      rates.sort_by(&:id).first
    end
  end

  def adjust(order, item)
    # We've overridden the class-level TaxRate.adjust so nothing should be calling this code
    raise SpreeAvatax::TaxRateInvalidOperation.new("Spree::TaxRate#adjust should never be called when Avatax is present")
  end

  private

  def avatax_there_can_be_only_one
    if Spree::TaxRate.count > 0
      errors.add(:base, "only one tax rate is allowed and this would make #{Spree::TaxRate.count+1}")
    end
  end
end
