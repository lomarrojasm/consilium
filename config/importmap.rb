# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"


pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/actioncable", to: "https://cdn.jsdelivr.net/npm/@rails/actioncable@7.1.3/app/assets/javascripts/actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
