import { Application } from "@hotwired/stimulus"
import SearchToggleController from "search_toggle_controller"

const application = Application.start()
application.register("search-toggle", SearchToggleController)

document.addEventListener("DOMContentLoaded", () => {
  const nav = document.getElementById("mobile-navbar");
  const heroSection = document.querySelector(".hero-section");
  const heroHeight = heroSection ? heroSection.offsetHeight : 200;

  window.addEventListener("scroll", () => {
    if (window.scrollY > heroHeight) {
      nav.classList.add("sticky-bottom");
    } else {
      nav.classList.remove("sticky-bottom");
    }
  });
});
