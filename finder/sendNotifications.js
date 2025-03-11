const admin = require('firebase-admin');
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
      const message = {
        notification: {
          title: 'New Message Received',
          body: messageText,
        },
        data: {
          senderId: senderId,
          message: messageText,
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
// testNotification();