# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.1/dist/stimulus.js"
pin "search_toggle_controller", to: "controllers/search_toggle_controller.js"
pin "reset_form_controller", to: "controllers/reset_form_controller.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/dist/esm/popper.js"
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.0/dist/js/bootstrap.esm.js"
