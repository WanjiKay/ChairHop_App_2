# Pin npm packages by running ./bin/importmap

pin "application"
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.1/dist/stimulus.js"
pin "search_toggle_controller", to: "controllers/search_toggle_controller.js"
