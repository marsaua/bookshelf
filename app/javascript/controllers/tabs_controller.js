import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "panel"];

  connect() {
    this.showPanel(0);
  }

  switch(event) {
    const index = this.tabTargets.indexOf(event.currentTarget);
    this.showPanel(index);
  }

  showPanel(index) {
    this.tabTargets.forEach((tab, i) => {
      if (i === index) {
        tab.classList.add("active-tab");
        tab.classList.remove("tab");
      } else {
        tab.classList.remove("active-tab");
        tab.classList.add("tab");
      }
    });

    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.classList.remove("hidden");
      } else {
        panel.classList.add("hidden");
      }
    });
  }
}
