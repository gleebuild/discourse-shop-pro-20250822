# frozen_string_literal: true
class DiscourseShop::Admin::CouponsController < ::Admin::AdminController
  requires_plugin ::DiscourseShop::PLUGIN_NAME

  def index
    q = DiscourseShop::Coupon.all
    if params[:status].present?
      q = q.where(status: DiscourseShop::Coupon.statuses[params[:status]])
    end
    if params[:kw].present?
      like = "%#{params[:kw]}%"
      q = q.where("code like ?", like)
    end
    q = q.order(updated_at: :desc)
    render_json_dump(coupons: q.limit(200))
  end

  def create
    guardian.ensure_can_manage_shop!
    c = DiscourseShop::Coupon.new(coupon_params)
    c.code = c.code.upcase
    c.save!
    render_json_dump(c)
  end

  def update
    guardian.ensure_can_manage_shop!
    c = DiscourseShop::Coupon.find(params[:id])
    c.update!(coupon_params)
    render_json_dump(c)
  end

  def destroy
    guardian.ensure_can_manage_shop!
    c = DiscourseShop::Coupon.find(params[:id])
    c.destroy!
    render_json_dump(ok: true)
  end

  private

  def coupon_params
    params.require(:coupon).permit(:code, :discount_type, :value, :starts_at, :ends_at, :status, :max_uses)
  end
end
