# frozen_string_literal: true
class DiscourseShop::OrderSerializer < ApplicationSerializer
  attributes :id, :status, :currency, :total_cents, :discount_cents, :payment_method,
             :items, :shipping, :coupon_code, :provider, :provider_trade_no

  def items
    object.items_json || []
  end

  def shipping
    object.shipping_json || {}
  end

  def coupon_code
    object.coupon&.code
  end

  def provider
    object.provider
  end
end
