import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";

export default class ShopOrderCompleteController extends Controller {
  @tracked orderId = null;
  @tracked status = null;
  constructor() {
    super(...arguments);
    const q = new URLSearchParams(window.location.search);
    this.orderId = q.get("order_id");
    this.status = q.get("status") || "success";
  }
}
