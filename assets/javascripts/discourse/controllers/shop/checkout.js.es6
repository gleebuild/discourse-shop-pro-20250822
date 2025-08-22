import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";

export default class ShopCheckoutController extends Controller {
  queryParams = ["product_id"];
  @tracked product_id = null;
  @tracked product = null;
  @tracked loading = true;
  @tracked addr = {};
  @tracked coupon = "";
  @tracked subtotal = 0;
  @tracked discount = 0;
  @tracked total = 0;
  @tracked currency = "CNY";
  @tracked paymentMethod = "wechat";

  constructor() {
    super(...arguments);
    this.initLoad();
  }

  async initLoad() {
    this.loading = true;
    const p = await ajax(`/shop/products/${this.params.product_id}.json`);
    this.product = p;
    this.subtotal = p.price_cents;
    this.currency = p.currency;
    this.loading = false;
  }

  @action setField(k, ev) { this.addr[k] = ev.target.value; }
  @action setCoupon(ev) { this.coupon = ev.target.value; }
  @action setPM(ev) { this.paymentMethod = ev.target.value; }

  @action
  async applyCoupon() {
    const resp = await ajax("/shop/checkout/price", {
      type: "POST",
      data: { subtotal_cents: this.subtotal, coupon: this.coupon }
    });
    this.discount = resp.discount_cents;
    this.total = resp.total_cents;
  }

  @action
  async placeOrder() {
    if (!this.total) {
      this.total = this.subtotal - (this.discount || 0);
    }
    const items = [{
      product_id: this.product.id,
      name: this.product.name,
      price_cents: this.product.price_cents,
      qty: 1
    }];

    const resp = await ajax("/shop/orders", {
      type: "POST",
      data: {
        items, shipping: this.addr,
        coupon: this.coupon,
        discount_cents: this.discount,
        total_cents: this.total,
        payment_method: this.paymentMethod
      }
    });

    if (resp.ok && resp.payment && resp.payment.redirect_url) {
      window.location = resp.payment.redirect_url;
    } else {
      bootbox.alert("下单失败");
    }
  }
}
