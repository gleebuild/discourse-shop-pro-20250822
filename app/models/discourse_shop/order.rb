# frozen_string_literal: true
module DiscourseShop
  class Order < ActiveRecord::Base
    self.table_name = "shop_orders"

    enum status: { created: 0, paying: 1, paid: 2, cancelled: 3, fulfilled: 4 }

    belongs_to :coupon, class_name: "DiscourseShop::Coupon", optional: true
    belongs_to :user, class_name: "User", optional: true

    serialize :items_json, JSON
    serialize :shipping_json, JSON
    serialize :provider_payload_json, JSON

    validates :currency, presence: true
    validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

    def mark_paid!(provider_trade_no: nil, payload: {})
      self.status = :paid
      self.provider_trade_no = provider_trade_no if provider_trade_no
      self.provider_payload_json = payload if payload
      save!
    end
  end
end
