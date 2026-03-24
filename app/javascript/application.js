// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"

// Este evento se dispara SIEMPRE que Turbo termina de cambiar de página

document.addEventListener("turbo:load", function() {

console.log("🚀 Turbo cargó: Reiniciando jQuery y Hyper...");



// 1. Si tu plantilla tiene un objeto global de inicialización

if (window.App && typeof window.App.init === 'function') {

window.App.init();

}



// 2. Si usas componentes específicos de Bootstrap que se rompen

// Re-inicializa tooltips, por ejemplo:

if (typeof bootstrap !== 'undefined') {

const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')

tooltipTriggerList.forEach(el => new bootstrap.Tooltip(el))

}

});


if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then(registration => console.log('SW registrado con éxito'))
      .catch(err => console.log('SW error de registro:', err));
  });
}