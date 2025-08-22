import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";

export default class ShopProductController extends Controller {
  @tracked loading = true;
  @tracked product = null;
  @tracked selected = {};

  constructor() {
    super(...arguments);
    this.load();
  }

  get id() {
    return this.model?.id || this.params?.id;
  }

  async load() {
    this.loading = true;
    const resp = await ajax(`/shop/products/${this.params.id}.json`);
    this.product = resp;
    (this.product.options_schema || []).forEach((opt) => {
      this.selected[opt.name] = opt.values[0];
    });
    this.loading = false;
  }

  @action
  setOption(name, ev) {
    this.selected[name] = ev.target.value;
  }

  @action
  toCheckout() {
    this.transitionToRoute("shop.checkout", { queryParams: { product_id: this.product.id } });
  }
}
