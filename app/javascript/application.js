import "@hotwired/turbo-rails"

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

  // AVATAR DROPDOWN
  const avatarToggle = document.querySelector(".avatar-dropdown-toggle");
  const dropdownMenu = document.querySelector(".dropdown-menu");

  if (avatarToggle && dropdownMenu) {
    const handleAvatarClick = (event) => {
      event.preventDefault();
      event.stopPropagation();
      dropdownMenu.classList.toggle("show");
    };

    const handleDocumentClick = (event) => {
      if (
        !dropdownMenu.contains(event.target) &&
        !avatarToggle.contains(event.target)
      ) {
        dropdownMenu.classList.remove("show");
      }
    };

    avatarToggle.addEventListener("click", handleAvatarClick);
    document.addEventListener("click", handleDocumentClick);
  }
}

// Use Turbo lifecycle so it works on every page
document.addEventListener("turbo:load", initNavbar);
