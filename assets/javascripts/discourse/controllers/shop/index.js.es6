import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";

export default class ShopIndexController extends Controller {
  @tracked products = [];
  @tracked loading = true;

  constructor() {
    super(...arguments);
    this.load();
  }

  async load() {
    this.loading = true;
    const resp = await ajax("/shop/products.json");
    this.products = resp.products || [];
    this.loading = false;
  }

  @action
  goProduct(id) {
    this.transitionToRoute("shop.product", id);
  }
}
