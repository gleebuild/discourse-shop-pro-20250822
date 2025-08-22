import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";

export default {
  name: "discourse-shop-pro-20250822",
  initialize(container) {
    withPluginApi("1.27.0", (api) => {
      if (!api.container.lookup("site-settings:main").shop_enabled) {
        return;
      }

      // ---- Routes ----
      api.addRoute("shop.index", { path: "/shop" });
      api.addRoute("shop.product", { path: "/shop/product/:id" });
      api.addRoute("shop.checkout", { path: "/shop/checkout" });
      api.addRoute("shop.order-complete", { path: "/shop-client/order-complete" });
      api.addRoute("shop.admin", { path: "/shop/admin" });

      // ---- Navigation (Home: 最新/热门/类别 右侧增加 “商城 / 管理”) ----
      api.decorateWidget("discovery-navigation", (helper) => {
        let contents = [];

        contents.push(helper.h("li.nav-item.shop-tab", [
          helper.h("a", { href: "/shop", attributes: { "data-auto-route": true } }, I18n.t("discourse_shop.nav.shop"))
        ]));

        if (helper.currentUser && (helper.currentUser.staff)) {
          contents.push(helper.h("li.nav-item.shop-admin-tab", [
            helper.h("a", { href: "/shop/admin", attributes: { "data-auto-route": true } }, I18n.t("discourse_shop.nav.admin"))
          ]));
        }

        return contents;
      });

      // ---- Simple current-user guard for admin page ----
      api.modifyClass("controller:shop-admin", {
        actions: {
          ensureStaff() {
            if (!this.currentUser || !this.currentUser.staff) {
              bootbox.alert("Only staff can access shop admin.");
              this.transitionToRoute("shop.index");
            }
          }
        }
      });
    });
  },
};
