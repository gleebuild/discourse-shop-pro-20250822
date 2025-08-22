# frozen_string_literal: true
class DiscourseShop::Public::PaymentsController < ::ApplicationController
  requires_plugin ::DiscourseShop::PLUGIN_NAME
  skip_before_action :verify_authenticity_token

  # Provider plugins should post to /shop/payments/webhook/:provider
  def webhook
    provider = params[:provider].to_s
    order_id = params[:order_id] || params.dig(:data, :order_id) || params.dig(:resource, :order_id)
    status = params[:status] || params.dig(:data, :status)

    if order_id.blank?
      return render_json_error("missing order_id", status: 400)
    end

    order = DiscourseShop::Order.find_by(id: order_id)
    unless order
      return render_json_error("order not found", status: 404)
    end

    if status.to_s == "success" || status.to_s == "paid"
      order.mark_paid!(provider_trade_no: params[:trade_no], payload: params.to_unsafe_h)
      DiscourseWechatHomeLogger.log!("order #{order.id} marked paid by #{provider}")
      render_json_dump(ok: true)
    else
      render_json_dump(ok: true, note: "ignored status #{status}")
    end
  rescue => e
    render_json_error(e.message, status: 500)
  end

  def initiate
    render_json_error("use /shop/orders to create order and initiate payments", status: 400)
  end
end
