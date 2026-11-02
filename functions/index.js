
const { setGlobalOptions } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");

const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

// Create Worker Account
exports.createWorker = onCall(async (request) => {
  // 1. Check Authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  const managerUid = request.auth.uid;

  // 2. Get Manager Data
  const firestore = getFirestore();
  const managerDoc = await firestore
      .collection("users")
      .doc(managerUid)
      .get();

  if (!managerDoc.exists) {
    throw new HttpsError(
      "permission-denied",
      "Manager account not found."
    );
  }

  const managerData = managerDoc.data();

  // 3. Verify Manager Role
  if (
    managerData.role !== "manager" ||
    managerData.isActive !== true
  ) {
    throw new HttpsError(
      "permission-denied",
      "Only active managers can create workers."
    );
  }

  // 4. Validate Input
  const { name, email, password } = request.data || {};

  if (
    typeof name !== "string" ||
    !name.trim() ||
    typeof email !== "string" ||
    !email.trim() ||
    typeof password !== "string" ||
    password.length < 6
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide a valid name, email, and password (at least 6 characters)."
    );
  }

  const workerName = name.trim();
  const workerEmail = email.trim().toLowerCase();

  let worker;

  try {
    // 5. Create Firebase Authentication Account
    worker = await getAuth().createUser({
      email: workerEmail,
      password: password,
      displayName: workerName,
      disabled: false,
    });

    // 6. Save Worker Data in Firestore
    await firestore
        .collection("users")
        .doc(worker.uid)
        .set({
          uid: worker.uid,
          name: workerName,
          email: workerEmail,
          role: "worker",
          isActive: true,
          createdAt: FieldValue.serverTimestamp(),
          createdBy: managerUid,
        });

    return {
      success: true,
      uid: worker.uid,
      message: "Worker account created successfully.",
    };
  } catch (error) {
    // 7. Rollback Auth Account if Firestore Save Fails
    if (worker) {
      try {
        await getAuth().deleteUser(worker.uid);
      } catch (deleteError) {
        console.error(
          "Failed to rollback worker account:",
          deleteError
        );
      }
    }

    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Create Worker Error:", error);

    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "This email is already registered."
      );
    }

    throw new HttpsError(
      "internal",
      "Failed to create worker account."
    );
  }
});

// Update Worker Status (Activate / Deactivate)
exports.updateWorkerStatus = onCall(async (request) => {
  // 1. Check Authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  const managerUid = request.auth.uid;

  // 2. Get Manager Data
  const firestore = getFirestore();

  const managerDoc = await firestore
      .collection("users")
      .doc(managerUid)
      .get();

  if (!managerDoc.exists) {
    throw new HttpsError(
      "permission-denied",
      "Manager account not found."
    );
  }

  const managerData = managerDoc.data();

  // 3. Verify Manager Role
  if (
    managerData.role !== "manager" ||
    managerData.isActive !== true
  ) {
    throw new HttpsError(
      "permission-denied",
      "Only active managers can update worker status."
    );
  }

  // 4. Validate Input
  const { workerId, isActive } = request.data || {};

  if (
    typeof workerId !== "string" ||
    !workerId.trim() ||
    typeof isActive !== "boolean"
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide a valid workerId and isActive value."
    );
  }

  const targetWorkerId = workerId.trim();

  // 5. Get Worker Data
  const workerRef = firestore
      .collection("users")
      .doc(targetWorkerId);

  const workerDoc = await workerRef.get();

  if (!workerDoc.exists) {
    throw new HttpsError(
      "not-found",
      "Worker account not found."
    );
  }

  const workerData = workerDoc.data();

  // 6. Make Sure Target Is A Worker
  if (workerData.role !== "worker") {
    throw new HttpsError(
      "permission-denied",
      "You can only update worker accounts."
    );
  }

  let previousDisabled;

  try {
    // 7. Get Current Authentication Account
    const authUser = await getAuth().getUser(targetWorkerId);

    previousDisabled = authUser.disabled;

    // 8. Update Firebase Authentication
    await getAuth().updateUser(targetWorkerId, {
      disabled: !isActive,
    });

    // 9. Update Firestore
    await workerRef.update({
      isActive: isActive,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: managerUid,
    });

    return {
      success: true,
      workerId: targetWorkerId,
      isActive: isActive,
      message: isActive
        ? "Worker activated successfully."
        : "Worker deactivated successfully.",
    };

  } catch (error) {
    // 10. Rollback Authentication If Firestore Update Fails
    if (previousDisabled !== undefined) {
      try {
        await getAuth().updateUser(targetWorkerId, {
          disabled: previousDisabled,
        });
      } catch (rollbackError) {
        console.error(
          "Failed to rollback Authentication status:",
          rollbackError
        );
      }
    }

    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Update Worker Status Error:", error);

    if (error.code === "auth/user-not-found") {
      throw new HttpsError(
        "not-found",
        "Worker Authentication account not found."
      );
    }

    throw new HttpsError(
      "internal",
      "Failed to update worker status."
    );
  }
});
