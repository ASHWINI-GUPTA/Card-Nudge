// Give the service worker access to Firebase Messaging.
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// the app's FirebaseConfig.
firebase.initializeApp({
  apiKey: "AIzaSyCVzPbJVSV1jj4W7a1PAuCHWnn39Htoh8I",
  appId: "1:896348195696:web:ea8f12decb18612dc69db5",
  messagingSenderId: "896348195696",
  projectId: "in-fnlsg-card",
  authDomain: "in-fnlsg-card.firebaseapp.com",
  storageBucket: "in-fnlsg-card.firebasestorage.app",
  measurementId: "G-WRM8FTR8RV"
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || 'Card Nudge Alert';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
