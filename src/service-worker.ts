import {manifest, version} from '@parcel/service-worker';

const install = async () => {
  const cache = await caches.open(version);
  await cache.addAll([ ...manifest, "/repl.wasm"]);
}
self.addEventListener('install', (e: any) => e.waitUntil(install()));

const activate = async () => {
  const keys = await caches.keys();
  await Promise.all(
    keys.map(key => {
      if (key !== version) {
        caches.delete(key)
      }
    })
  );
}
self.addEventListener('activate', (e: any) => e.waitUntil(activate()));

const fetchHander = (e: any) => {
  e.respondWith(
    caches.match(e.request).then((r) => {
      return r || fetch(e.request).then((response) => {
                return caches.open(version).then((cache) => {
          cache.put(e.request, response.clone());
          return response;
        });
      });
    })
  );
};
self.addEventListener('fetch', fetchHander);