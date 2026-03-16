import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "line"]

  toggle() {
    const menu = this.menuTarget
    const isOpen = !menu.classList.contains("hidden")

    menu.classList.toggle("hidden", isOpen)
    menu.classList.toggle("flex", !isOpen)

    if (!isOpen) {
      this.lineTargets[0].style.transform = "translateY(8px) rotate(45deg)"
      this.lineTargets[1].style.opacity = "0"
      this.lineTargets[2].style.transform = "translateY(-8px) rotate(-45deg)"
    } else {
      this.lineTargets[0].style.transform = ""
      this.lineTargets[1].style.opacity = ""
      this.lineTargets[2].style.transform = ""
    }
  }
}