importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyCenJjnPLn8bmPMtbhF8Fmacj2wJj2HLas',
  appId: '1:714209090598:web:6a9a8bcc650c3f59be5ae7',
  messagingSenderId: '714209090598',
  projectId: 'chromosome-app-d6167',
  authDomain: 'chromosome-app-d6167.firebaseapp.com',
  storageBucket: 'chromosome-app-d6167.firebasestorage.app',
});

const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage((payload) => {
  console.log("Received background message ", payload);
  
  // Robust check for title and body from both notification and data
  const notificationTitle = 
    (payload.notification && payload.notification.title) || 
    (payload.data && payload.data.title) || 
    "Thông báo mới";
    
  const notificationOptions = {
    body: 
      (payload.notification && payload.notification.body) || 
      (payload.data && payload.data.body) || 
      "Bạn có một thông báo mới từ hệ thống.",
    icon: "/icons/Icon-192.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
