# frozen_string_literal: true
class DiscourseShop::Public::CheckoutController < ::ApplicationController
  requires_plugin ::DiscourseShop::PLUGIN_NAME

  def price
    currency = SiteSetting.shop_currency
    subtotal = params[:subtotal_cents].to_i
    coupon_code = params[:coupon].to_s.strip
    discount = 0
    coupon = nil

    if coupon_code.present?
      coupon = DiscourseShop::Coupon.find_by(code: coupon_code.upcase)
      if coupon&.valid_now?
        discount = coupon.apply_to(subtotal)
      end
    end

    total = [subtotal - discount, 0].min + [subtotal - discount, 0].max # safeguard
    render_json_dump(currency: currency, subtotal_cents: subtotal, discount_cents: discount, total_cents: total)
  end
end
