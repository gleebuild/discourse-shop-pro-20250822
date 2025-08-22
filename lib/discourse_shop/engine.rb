# frozen_string_literal: true
module ::DiscourseShop
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace ::DiscourseShop
  end
end

::DiscourseShop::Engine.routes.draw do
  scope module: :public do
    resources :products, only: [:index, :show]
    post "checkout/price" => "checkout#price"
    post "orders" => "orders#create"
    get  "orders/:id" => "orders#show"
    post "payments/initiate" => "payments#initiate"
    post "payments/webhook/:provider" => "payments#webhook"
  end

  scope module: :admin, path: "admin" do
    resources :products
    resources :coupons
    resources :orders do
      member do
        patch :fulfill
      end
    end
  end
end

Discourse::Application.routes.append do
  mount ::DiscourseShop::Engine, at: "/shop"
end
