importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDl8o9JoOpmhmBX56irgztejfc1CMFD78g",
  authDomain: "sigetu-b10c0.firebaseapp.com",
  projectId: "sigetu-b10c0",
  storageBucket: "sigetu-b10c0.appspot.com",
  messagingSenderId: "882177455207",
  appId: "1:882177455207:web:3b807841f710f4c26e90c2"
});

const messaging = firebase.messaging();

// Handler para mostrar notificaciones push en segundo plano
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Recibido mensaje en background:', payload);
  const notificationTitle = payload.notification?.title || 'Notificación';
  const notificationOptions = {
    body: payload.notification?.body,
    icon: payload.notification?.icon || '/icons/icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
