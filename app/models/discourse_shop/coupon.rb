# frozen_string_literal: true
module DiscourseShop
  class Coupon < ActiveRecord::Base
    self.table_name = "shop_coupons"

    enum discount_type: { percent: 0, amount: 1 }
    enum status: { enabled: 0, disabled: 1, voided: 2 }

    validates :code, presence: true, uniqueness: true

    def valid_now?
      now = Time.now
      (starts_at.nil? || now >= starts_at) && (ends_at.nil? || now <= ends_at) && enabled?
    end

    def apply_to(subtotal_cents)
      return 0 unless valid_now?
      if percent?
        (subtotal_cents * (value.to_f / 100.0)).to_i
      else
        [value.to_i, subtotal_cents].min
      end
    end
  end
end
