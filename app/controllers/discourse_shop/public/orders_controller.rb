# frozen_string_literal: true
class DiscourseShop::Public::OrdersController < ::ApplicationController
  requires_plugin ::DiscourseShop::PLUGIN_NAME

  def create
    params.require(:items)
    params.require(:shipping)
    gateway = params[:payment_method].presence || "noop"

    # coupon
    coupon = nil
    if params[:coupon].present?
      coupon = DiscourseShop::Coupon.find_by(code: params[:coupon].to_s.upcase)
    end

    order = DiscourseShop::Order.new(
      user_id: current_user&.id,
      status: :paying,
      currency: SiteSetting.shop_currency,
      items_json: params[:items],
      shipping_json: params[:shipping],
      coupon_id: coupon&.id,
      discount_cents: params[:discount_cents].to_i,
      total_cents: params[:total_cents].to_i,
      payment_method: gateway
    )
    order.save!

    # initiate payment via provider registry
    return_url = "#{Discourse.base_url}/shop-client/order-complete?order_id=#{order.id}"
    notify_url = "#{Discourse.base_url}/shop/payments/webhook/#{gateway}"
    provider_klass = ::DiscourseShop::Payment::Gateway.for(gateway) || ::DiscourseShop::Payment::Gateway::Noop
    init = provider_klass.initiate(order: order, return_url: return_url, notify_url: notify_url, context: {})

    DiscourseWechatHomeLogger.log!("create order #{order.id} via #{gateway}")
    render_json_dump(ok: true, order_id: order.id, payment: init)
  rescue => e
    DiscourseWechatHomeLogger.log!("order create error: #{e}")
    render_json_error(e.message)
  end

  def show
    o = DiscourseShop::Order.find(params[:id])
    guardian.ensure_can_see!(o.user) if o.user_id.present?
    render_json_dump(DiscourseShop::OrderSerializer.new(o, root: false))
  rescue ActiveRecord::RecordNotFound
    render_json_error("order_not_found", status: 404)
  end
end
