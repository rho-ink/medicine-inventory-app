/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Log Gudang updates
exports.logGudangUpdate = functions.database.ref("/gudangData/{gudangId}")
    .onUpdate(async (change, context) => {
      const before = change.before.val();
      const after = change.after.val();
      const gudangId = context.params.gudangId;
      const timestamp = new Date().toISOString();
      const logRef = admin.database().ref("/gudangLog");
      const logId = logRef.push().key;

      const logEntry = {
        timestamp: timestamp,
        action: "update",
        gudangId: gudangId,
        before: before,
        after: after,
      };

      await logRef.child(logId).set(logEntry);
      console.log(`Logged update for Gudang ID: ${gudangId}`);

      return null;
    });

// Log Expiry Detail Deletion
exports.logExpiryDetailDelete = functions.database.ref("/gudangData/{gudangId}/expiryDetails/{expiryDate}")
    .onDelete(async (snapshot, context) => {
      const deletedDetail = snapshot.val(); // Data before deletion
      const gudangId = context.params.gudangId;
      const expiryDate = context.params.expiryDate;
      const timestamp = new Date().toISOString();
      const logRef = admin.database().ref("/gudangLog");
      const logId = logRef.push().key;

      // Check if deletedDetail is null
      if (!deletedDetail) {
        console.log(`No data found for expiry detail at Gudang ID: ${gudangId}, Expiry Date: ${expiryDate}. Skipping log.`);
        return null;
      }

      // Extract the current quantity before deletion
      const currentQuantity = deletedDetail.quantity || 0;

      // Log entry
      const logEntry = {
        timestamp: timestamp,
        action: "delete_expiry_detail",
        gudangId: gudangId,
        expiryDate: expiryDate,
        currentQuantity: currentQuantity, // Log the quantity before deletion
        deletedDetail: deletedDetail,
      };

      try {
        await logRef.child(logId).set(logEntry);
        console.log(`Logged expiry detail deletion for Gudang ID: ${gudangId}, Expiry Date: ${expiryDate}`);
      } catch (error) {
        console.error(`Failed to log expiry detail deletion for Gudang ID: ${gudangId}, Expiry Date: ${expiryDate}`, error);
      }

      return null;
    });


// roleassign
exports.assignRoleOnSignup = functions.auth.user().onCreate(async (user) => {
  const userRef = admin.database().ref(`/users/${user.uid}`);
  await userRef.set({
    email: user.email,
    role: "user", // Default role assignment
  });
});


// rolelogging
exports.onRoleChange = functions.database.ref("/users/{uid}/role")
    .onUpdate((change, context) => {
      const beforeRole = change.before.val();
      const afterRole = change.after.val();
      console.log(`Role changed from ${beforeRole} to ${afterRole} for user ${context.params.uid}`);

    // Implement any additional logic, such as sending notifications or validating changes
    });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
