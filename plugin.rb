# frozen_string_literal: true
# name: discourse-shop-pro-20250822
# about: Full-featured Shop for Discourse (products/orders/coupons) with pluggable payment gateways (WeChat/PayPal via separate plugins)
# version: 1.0.0
# authors: GleeBuild + ChatGPT
# required_version: 3.0.0

enabled_site_setting :shop_enabled

register_asset 'stylesheets/common/discourse-shop-pro.scss'

# ---- 1) 统一日志工具（写文件到 /var/www/discourse/public/wechat.txt）----
module ::DiscourseWechatHomeLogger
  LOG_DIR  = "/var/www/discourse/public"
  LOG_FILE = File.join(LOG_DIR, "wechat.txt")
  HOMEPATHS = ['/', '/latest', '/categories', '/top', '/new', '/hot'].freeze

  def self.log!(message)
    begin
      FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      File.open(LOG_FILE, "a") { |f| f.puts("#{timestamp} | #{message}") }
    rescue => e
      Rails.logger.warn("[wechat-home-logger] write error: #{e.class}: #{e.message}")
    end
  end
end

after_initialize do
  module ::DiscourseShop
    PLUGIN_NAME = "discourse-shop-pro-20250822"
  end

  require_relative "lib/discourse_shop/engine"
  require_relative "lib/discourse_shop/payment/gateway"

  # Basic guardian: allow all to view products, only staff to manage
  class ::Guardian
    def can_manage_shop?
      user && (user.admin? || user.moderator?)
    end
  end

  # Log some boot info
  DiscourseWechatHomeLogger.log!("Shop plugin booted.")
end
