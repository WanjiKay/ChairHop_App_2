import "@hotwired/turbo-rails"
import * as bootstrap from "bootstrap"

import { Application } from "@hotwired/stimulus"
import SearchToggleController from "search_toggle_controller"

const application = Application.start()
application.register("search-toggle", SearchToggleController)

function initNavbar() {
  // Prevent double-initialization on Turbo navigation
  if (document.body.dataset.navbarInitialized === "true") return;
  document.body.dataset.navbarInitialized = "true";

  const nav = document.getElementById("mobile-navbar");
  const heroSection = document.querySelector(".hero-section");

  // STICKY NAVBAR ON SCROLL
  if (nav) {
    const heroHeight = heroSection ? heroSection.offsetHeight : 0;

    window.addEventListener("scroll", () => {
      if (window.scrollY > heroHeight) {
        nav.classList.add("sticky-top");
      } else {
        nav.classList.remove("sticky-top");
      }
    });
  }

  // MOBILE NAVBAR TOGGLER (HAMBURGER)
  const toggler = document.querySelector(".navbar-toggler");
  const collapse = document.getElementById("navbarSupportedContent");

  if (toggler && collapse) {
    toggler.addEventListener("click", (event) => {
      event.preventDefault();
      collapse.classList.toggle("show");
    });
  }

}

// Reinitialize Bootstrap dropdowns after Turbo navigation
document.addEventListener("turbo:load", () => {
  // Initialize all Bootstrap dropdowns
  const dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]');
  if (typeof bootstrap !== 'undefined') {
    dropdownElementList.forEach((dropdownToggleEl) => {
      new bootstrap.Dropdown(dropdownToggleEl);
    });
  }
});

// Use Turbo lifecycle so it works on every page
document.addEventListener("turbo:load", initNavbar);
