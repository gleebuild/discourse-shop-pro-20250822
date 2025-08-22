import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class ShopAdminController extends Controller {
  @tracked products = [];
  @tracked coupons = [];
  @tracked orders = [];
  @tracked kw = "";
  @tracked status = "";
  @tracked kwCoupon = "";
  @tracked kwOrder = "";
  @tracked orderStatus = "";

  @tracked newP = { name: "", price_cents: 0, currency: "CNY", image: "" };
  @tracked newC = { code: "", discount_type: "percent", value: 10 };

  constructor() {
    super(...arguments);
    this.loadProducts();
    this.loadCoupons();
    this.loadOrders();
  }

  @action setKw(ev) { this.kw = ev.target.value; }
  @action setStatus(ev) { this.status = ev.target.value; }
  @action setKwCoupon(ev) { this.kwCoupon = ev.target.value; }
  @action setKwOrder(ev) { this.kwOrder = ev.target.value; }
  @action setOrderStatus(ev) { this.orderStatus = ev.target.value; }

  @action setNewP(k, ev) { this.newP[k] = ev.target.value; }
  @action setNewC(k, ev) { this.newC[k] = ev.target.value; }

  @action async createProduct() {
    const data = {
      product: {
        name: this.newP.name,
        price_cents: parseInt(this.newP.price_cents || 0, 10),
        currency: this.newP.currency || "CNY",
        status: "active",
        image_urls_json: this.newP.image ? [this.newP.image] : []
      }
    };
    await ajax("/shop/admin/products.json", { type: "POST", data });
    this.loadProducts();
  }

  @action async createCoupon() {
    const data = {
      coupon: {
        code: (this.newC.code || "").toUpperCase(),
        discount_type: this.newC.discount_type,
        value: parseInt(this.newC.value || 0, 10),
        status: "enabled"
      }
    };
    await ajax("/shop/admin/coupons.json", { type: "POST", data });
    this.loadCoupons();
  }

  @action async setStatusFor(p, st) {
    await ajax(`/shop/admin/products/${p.id}.json`, { type: "PUT", data: { product: { status: st } } });
    this.loadProducts();
  }

  @action async fulfill(o) {
    const data = { company: o._ship_company, tracking_no: o._ship_tracking };
    await ajax(`/shop/admin/orders/${o.id}/fulfill.json`, { type: "PATCH", data });
    this.loadOrders();
  }

  @action setShipField(o, k, ev) {
    if (k === "company") o._ship_company = ev.target.value;
    if (k === "tracking_no") o._ship_tracking = ev.target.value;
  }

  @action async loadProducts() {
    const resp = await ajax("/shop/admin/products.json", { data: { kw: this.kw, status: this.status } });
    this.products = resp.products || [];
  }

  @action async loadCoupons() {
    const resp = await ajax("/shop/admin/coupons.json", { data: { kw: this.kwCoupon } });
    this.coupons = resp.coupons || [];
  }

  @action async loadOrders() {
    const resp = await ajax("/shop/admin/orders.json", { data: { kw: this.kwOrder, status: this.orderStatus } });
    this.orders = resp.orders || [];
  }
}
