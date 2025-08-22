# frozen_string_literal: true
class DiscourseShop::Public::ProductsController < ::ApplicationController
  requires_plugin ::DiscourseShop::PLUGIN_NAME

  def index
    DiscourseWechatHomeLogger.log!("list products")
    products = DiscourseShop::Product.active_only.order(created_at: :desc).limit(200)
    render_json_dump(products: ActiveModel::ArraySerializer.new(products, each_serializer: DiscourseShop::ProductSerializer))
  end

  def show
    p = DiscourseShop::Product.find(params[:id])
    render_json_dump(DiscourseShop::ProductSerializer.new(p, root: false))
  rescue ActiveRecord::RecordNotFound
    render_json_error("product_not_found", status: 404)
  end
end
