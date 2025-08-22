# frozen_string_literal: true
class DiscourseShop::Admin::OrdersController < ::Admin::AdminController
  requires_plugin ::DiscourseShop::PLUGIN_NAME

  def index
    q = DiscourseShop::Order.all
    q = q.where(status: DiscourseShop::Order.statuses[params[:status]]) if params[:status].present?
    q = q.where(payment_method: params[:payment_method]) if params[:payment_method].present?
    if params[:kw].present?
      like = "%#{params[:kw]}%"
      q = q.where("provider_trade_no like ? or id::text like ?", like, like)
    end
    q = q.order(updated_at: :desc)
    render_json_dump(orders: q.limit(200).map { |o| DiscourseShop::OrderSerializer.new(o, root: false) })
  end

  def update
    guardian.ensure_can_manage_shop!
    o = DiscourseShop::Order.find(params[:id])
    o.update!(order_params)
    render_json_dump(DiscourseShop::OrderSerializer.new(o, root: false))
  end

  def fulfill
    guardian.ensure_can_manage_shop!
    o = DiscourseShop::Order.find(params[:id])
    ship = o.shipping_json || {}
    ship["company"] = params[:company] if params[:company].present?
    ship["tracking_no"] = params[:tracking_no] if params[:tracking_no].present?
    o.shipping_json = ship
    o.status = :fulfilled
    o.save!
    render_json_dump(DiscourseShop::OrderSerializer.new(o, root: false))
  end

  private

  def order_params
    params.require(:order).permit(:status, :provider_trade_no, :payment_method, :discount_cents, :total_cents)
  end
end
