# frozen_string_literal: true
class DiscourseShop::Admin::ProductsController < ::Admin::AdminController
  requires_plugin ::DiscourseShop::PLUGIN_NAME

  def index
    q = DiscourseShop::Product.all
    if params[:status].present?
      q = q.where(status: DiscourseShop::Product.statuses[params[:status]])
    end
    if params[:kw].present?
      like = "%#{params[:kw]}%"
      q = q.where("name like ? or description like ?", like, like)
    end
    q = q.order(updated_at: :desc)
    render_json_dump(products: q.limit(200).map { |p| DiscourseShop::ProductSerializer.new(p, root: false) })
  end

  def create
    guardian.ensure_can_manage_shop!
    p = DiscourseShop::Product.new(prod_params)
    p.save!
    render_json_dump(DiscourseShop::ProductSerializer.new(p, root: false))
  end

  def update
    guardian.ensure_can_manage_shop!
    p = DiscourseShop::Product.find(params[:id])
    p.update!(prod_params)
    render_json_dump(DiscourseShop::ProductSerializer.new(p, root: false))
  end

  def destroy
    guardian.ensure_can_manage_shop!
    p = DiscourseShop::Product.find(params[:id])
    p.destroy!
    render_json_dump(ok: true)
  end

  private

  def prod_params
    params.require(:product).permit(:name, :slug, :description, :price_cents, :currency, :status,
                                    image_urls_json: [], options_schema_json: [])
  end
end
