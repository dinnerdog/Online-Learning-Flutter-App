const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
// admin.initializeApp();

// exports.createAssignmentUsers = functions.firestore
//     .document("courses/{courseId}/assignments/{assignmentId}")
//     .onCreate(async (snap, context) => {
//       const courseId = context.params.courseId;
//       const assignmentId = context.params.assignmentId;
//       const db = admin.firestore();

//       const courseSnapshot = await db
//           .collection("course_users")
//           .where("courseId", "==", courseId)
//           . get();
//       const studentIds = courseSnapshot.docs.map((doc) => doc.data().userId);

//       const tasks = studentIds.map((userId) => {
//         const assignmentUserRef = db.collection("assignments_users").doc();
//         return assignmentUserRef.set({
//           assignmentId,
//           userId,
//           isSubmitted: false,
//           submissionUrl: null,
//           review: null,
//           score: null,
//         });
//       });

//       await Promise.all(tasks);
//     });
