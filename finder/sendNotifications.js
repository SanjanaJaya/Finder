const admin = require('firebase-admin');
const path = require('path');
const cron = require('node-cron');

// Resolve the path to the service account key
const serviceAccountPath = path.resolve(__dirname, 'finder-cc54d-firebase-adminsdk-fbsvc-5e3ff793d3.json');
console.log('Resolved path:', serviceAccountPath);

// Initialize Firebase Admin SDK
const serviceAccount = require(serviceAccountPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Function to fetch sender details (name and image)
const fetchSenderDetails = async (senderId) => {
  try {
    // Check the Person collection first
    const personSnapshot = await admin.firestore()
      .collection('Person')
      .where('uid', '==', senderId)
      .get();

    if (!personSnapshot.empty) {
      const senderData = personSnapshot.docs[0].data();
      return {
        name: `${senderData.First_Name} ${senderData.Last_Name}`,
        image: senderData.Image,
      };
    }

    // If not found in Person collection, check Lecturer collection
    const lecturerSnapshot = await admin.firestore()
      .collection('Lecturer')
      .where('uid', '==', senderId)
      .get();

    if (!lecturerSnapshot.empty) {
      const senderData = lecturerSnapshot.docs[0].data();
      return {
        name: `${senderData.L_First_Name} ${senderData.L_Last_Name}`,
        image: senderData.Image,
      };
    }

    return null; // Sender not found
  } catch (error) {
    console.error('Error fetching sender details:', error);
    return null;
  }
};

// Function to send notifications
const sendNotification = async (recipientId, messageText, senderId) => {
  try {
    // Fetch the recipient's details (either from Person or Lecturer collection)
    const recipientSnapshot = await admin.firestore()
      .collection('Person')
      .where('uid', '==', recipientId)
      .get();

    let recipientData;
    let collectionName = 'Person';

    if (recipientSnapshot.empty) {
      // If not found in Person collection, check Lecturer collection
      const lecturerSnapshot = await admin.firestore()
        .collection('Lecturer')
        .where('uid', '==', recipientId)
        .get();

      if (!lecturerSnapshot.empty) {
        recipientData = lecturerSnapshot.docs[0].data();
        collectionName = 'Lecturer';
      }
    } else {
      recipientData = recipientSnapshot.docs[0].data();
    }

    if (!recipientData) {
      console.log('Recipient not found:', recipientId);
      return;
    }

    const fcmToken = recipientData.fcmToken;

    if (fcmToken) {
      // Fetch sender details (name and image)
      const senderDetails = await fetchSenderDetails(senderId);

      if (!senderDetails) {
        console.log('Sender details not found for senderId:', senderId);
        return;
      }

      const message = {
        notification: {
          title: senderDetails.name, // Sender's name as the notification title
          body: messageText, // Message content as the notification body
        },
        data: {
          senderId: senderId,
          senderName: senderDetails.name, // Include sender's name in the data payload
          senderImage: senderDetails.image, // Include sender's image URL in the data payload
          message: messageText, // Include the message in the data payload
        },
        android: {
          notification: {
            imageUrl: senderDetails.image, // Add image URL for Android BigPictureStyle
          },
        },
        apns: {
          payload: {
            aps: {
              'mutable-content': 1, // Enable mutable content for iOS
            },
          },
          fcm_options: {
            image: senderDetails.image, // Add image URL for iOS
          },
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log('Notification sent successfully to:', recipientData.First_Name || recipientData.L_First_Name, recipientData.Last_Name || recipientData.L_Last_Name);
    } else {
      console.log('No FCM token found for recipient:', recipientData.First_Name || recipientData.L_First_Name, recipientData.Last_Name || recipientData.L_Last_Name);
    }
  } catch (error) {
    console.error('Error sending notification:', error);
  }
};

// Function to send "Mark your availability" notifications to all logged-in lecturers
const sendAvailabilityNotifications = async () => {
  try {
    // Fetch all logged-in lecturers
    const lecturersSnapshot = await admin.firestore()
      .collection('Lecturer')
      .where('isLoggedIn', '==', true)
      .get();

    if (lecturersSnapshot.empty) {
      console.log('No logged-in lecturers found.');
      return;
    }

    // Send notifications to each logged-in lecturer
    lecturersSnapshot.forEach((doc) => {
      const lecturerData = doc.data();
      const lecturerId = lecturerData.uid;

      // Send the notification
      sendNotification(lecturerId, 'Mark your availability', 'system');
    });

    console.log('Availability notifications sent to all logged-in lecturers.');
  } catch (error) {
    console.error('Error sending availability notifications:', error);
  }
};

// Schedule notifications at 9:00 AM and 5:00 PM on weekdays
cron.schedule('0 9,17 * * 1-5', () => {
  console.log('Sending availability notifications...');
  sendAvailabilityNotifications();
});

// Listen for new messages in the Messages collection
const setupMessageListener = () => {
  admin.firestore().collection('Messages')
    .onSnapshot((snapshot) => {
      snapshot.docChanges().forEach((change) => {
        if (change.type === 'added') {
          const messageData = change.doc.data();
          const { senderId, receiverId, message } = messageData;

          // Send notification to the receiver
          sendNotification(receiverId, message, senderId);
        }
      });
    }, (error) => {
      console.error('Error listening to Messages collection:', error);
    });
};

// Start the listener
setupMessageListener();

// Manual trigger for testing
const testNotification = async () => {
  console.log('Manually triggering notification...');
  await sendNotification('A7LgOt9tQcaj7MmNoPmh8HjFdca2', 'Test message', 'OCgfSJkPH6QOsA7T0AHEZrKBWEL2');
};

// Uncomment the line below to test notifications manually
testNotification();