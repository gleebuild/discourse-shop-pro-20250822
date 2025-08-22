# frozen_string_literal: true
module DiscourseShop
  class Product < ActiveRecord::Base
    self.table_name = "shop_products"

    enum status: { draft: 0, active: 1, archived: 2 }

    validates :name, presence: true
    validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :currency, presence: true

    scope :active_only, -> { where(status: statuses[:active]) }
  end
end
