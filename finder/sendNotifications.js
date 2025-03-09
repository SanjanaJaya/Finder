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
          data: {
            // Add custom data for the notification (e.g., image URL)
            image: 'https://i.imgur.com/Nw4EixQ.png', // Replace with your image URL
          },
          android: {
            notification: {
              imageUrl: 'https://i.imgur.com/Nw4EixQ.png', // Android-specific image
            },
          },
          apns: {
            payload: {
              aps: {
                'mutable-content': 1, // Enable mutable content for iOS
              },
            },
            fcm_options: {
              image: 'https://example.com/path/to/your/image.png', // iOS-specific image
            },
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

// Schedule the notification to run Monday to Friday at 9:00 AM and 5:00 PM
cron.schedule('0 9,17 * * 1-5', () => {
  console.log('Sending scheduled notifications...');
  sendNotification();
});

// Manual trigger for testing
const testNotification = async () => {
  console.log('Manually triggering notification...');
  await sendNotification();
};

// Uncomment the line below to test notifications manually
// testNotification();