importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyDWJjD_iuw8eY-hQtn5fJzMlVvym-Ll-V4",
    authDomain: "mpac-sports.firebaseapp.com",
    projectId: "mpac-sports",
    storageBucket: "mpac-sports.appspot.com",
    messagingSenderId: "398523306336",
    appId: "1:398523306336:web:18ecbfc7a90a414fa7ce05",
    measurementId: "G-X52P5LN336"
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });