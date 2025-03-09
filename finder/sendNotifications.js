const admin = require('firebase-admin');
const cron = require('node-cron');
const path = require('path');

// Resolve the path to the service account key
const serviceAccountPath = path.resolve(__dirname, 'finder-cc54d-firebase-adminsdk-fbsvc-17d9cd66cc.json');
console.log('Resolved path:', serviceAccountPath);

// Initialize Firebase Admin SDK
const serviceAccount = require(serviceAccountPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Function to send notifications
const sendNotification = async () => {
  try {
    // Fetch all lecturers who are logged in
    const lecturersSnapshot = await admin.firestore()
      .collection('Lecturer')
      .where('isLoggedIn', '==', true)
      .get();

    // Loop through each logged-in lecturer and send a notification
    lecturersSnapshot.forEach((doc) => {
      const lecturerData = doc.data();
      const fcmToken = lecturerData.fcmToken;

      if (fcmToken) {
        const message = {
          notification: {
            title: 'Mark Your Availability',
            body: 'Please update your availability for today.',
          },
          token: fcmToken,
        };

        admin.messaging().send(message)
          .then((response) => {
            console.log('Notification sent successfully to:', lecturerData.L_First_Name, lecturerData.L_Last_Name);
          })
          .catch((error) => {
            console.error('Error sending notification:', error);
          });
      } else {
        console.log('No FCM token found for lecturer:', lecturerData.L_First_Name, lecturerData.L_Last_Name);
      }
    });
  } catch (error) {
    console.error('Error fetching lecturers:', error);
  }
};

// Schedule the notification to run daily at 9:00 AM
cron.schedule('0 9 * * *', () => {
  console.log('Sending daily notifications...');
  sendNotification();
});

// Manual trigger for testing
const testNotification = async () => {
  console.log('Manually triggering notification...');
  await sendNotification();
};

// Uncomment the line below to test notifications manually
testNotification();