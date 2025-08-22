# frozen_string_literal: true
class DiscourseShop::ProductSerializer < ApplicationSerializer
  attributes :id, :name, :slug, :description, :price_cents, :currency, :status,
             :image_urls, :options_schema

  def image_urls
    (object.image_urls_json || [])
  end

  def options_schema
    object.options_schema_json || []
  end
end
