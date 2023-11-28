/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started


// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.addUserData = functions.auth.user().onCreate((user) => {
  const uid = user.uid;
  const email = user.email;

  const userRef = admin.firestore().collection("users").doc(uid);

  return userRef.set({
    email: email,
  });
});

exports.deleteUserData = functions.auth.user().onDelete((user) => {
  const uid = user.uid;
  const userRef = admin.firestore().collection("users").doc(uid);

  return userRef.delete();
});

/*
exports.updateUserDataOnEmailChange = functions.firestore
    .document("users/{userId}")
    .onUpdate((change, context) => {
      const newData = change.after.data();
      const previousData = change.before.data();

      if (newData.email !== previousData.email) {
        const uid = context.params.userId;

        const userRef = admin.firestore().collection("users").doc(uid);

        return userRef.update({
          email: newData.email,
        });
      }

      return null;
    });
*/