// Este script permite que la app sea instalada y funcione offline básicamente
self.addEventListener('install', (event) => {
  console.log('Service Worker: Instalado');
});

self.addEventListener('fetch', (event) => {
  // Aquí podríamos cachear archivos, por ahora solo dejamos que pasen las peticiones
  event.respondWith(fetch(event.request));
});