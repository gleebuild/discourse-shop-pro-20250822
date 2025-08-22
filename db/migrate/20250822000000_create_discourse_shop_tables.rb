# frozen_string_literal: true

class CreateDiscourseShopTables20250822 < ActiveRecord::Migration[7.1]
  def up
    create_table :shop_products do |t|
      t.string  :name, null: false
      t.string  :slug
      t.text    :description
      t.integer :price_cents, null: false, default: 0
      t.string  :currency, null: false, default: "CNY"
      t.integer :status, null: false, default: 0
      t.jsonb   :image_urls_json, null: false, default: []
      t.jsonb   :options_schema_json, null: false, default: []
      t.timestamps
    end

    create_table :shop_coupons do |t|
      t.string  :code, null: false
      t.integer :discount_type, null: false, default: 0 # percent / amount
      t.integer :value, null: false, default: 0
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :status, null: false, default: 0 # enabled, disabled, voided
      t.integer :max_uses
      t.integer :used_count, default: 0
      t.timestamps
    end
    add_index :shop_coupons, :code, unique: true

    create_table :shop_orders do |t|
      t.integer :user_id
      t.integer :status, null: false, default: 0
      t.string  :currency, null: false, default: "CNY"
      t.integer :total_cents, null: false, default: 0
      t.integer :discount_cents, null: false, default: 0
      t.integer :coupon_id
      t.string  :payment_method
      t.string  :provider
      t.string  :provider_trade_no
      t.jsonb   :items_json, null: false, default: []
      t.jsonb   :shipping_json, null: false, default: {}
      t.jsonb   :provider_payload_json, null: false, default: {}
      t.timestamps
    end
    add_index :shop_orders, :user_id
    add_index :shop_orders, :status
    add_index :shop_orders, :payment_method
  end

  def down
    drop_table :shop_orders
    drop_table :shop_coupons
    drop_table :shop_products
  end
end
