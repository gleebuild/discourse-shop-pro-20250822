# discourse-shop-pro-20250822

A compact, production-ready **Discourse Shop** plugin skeleton that supports:
- Products (grid: mobile 2 per row, desktop 4 per row)
- Coupons (percent / amount, validity window, status)
- Orders (address fields, coupon, totals)
- Pluggable payment gateways (WeChat / PayPal via external plugins)
- Admin JSON APIs + a light Admin UI at `/shop/admin`
- File logging to `/var/www/discourse/public/wechat.txt`

## Install

Add to your app.yml under `hooks.after_code`:
```
- git clone https://example.invalid/discourse-shop-pro-20250822.git
```
(or upload the zip into plugins folder)

Then rebuild:
```
./launcher rebuild app
```

## Frontend routes
- `/shop` product list
- `/shop/product/:id` product detail
- `/shop/checkout?product_id=:id` checkout
- `/shop-client/order-complete?order_id=&status=` completion
- `/shop/admin` lightweight admin

## Payment integration
Other plugins can register a gateway:
```ruby
::DiscourseShop::Payment::Gateway.register("wechat", MyWechatGateway)
```
The gateway class must implement:
```ruby
def self.initiate(order:, return_url:, notify_url:, context: {})
  { ok: true, redirect_url: "..." }
end
```

Webhook endpoint for providers:
`POST /shop/payments/webhook/:provider` with at least `order_id` & `status`.

## Database tables
Created by `db/migrate/20250822000000_create_discourse_shop_tables.rb`.

Enjoy!
