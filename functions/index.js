const { setGlobalOptions } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
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

// Initialize Inventory From Existing Production Records
exports.initializeInventory = onCall(async (request) => {
  // 1. Check Authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  const firestore = getFirestore();
  const managerUid = request.auth.uid;

  // 2. Verify Active Manager
  const managerDoc = await firestore
    .collection("users")
    .doc(managerUid)
    .get();

  if (
    !managerDoc.exists ||
    managerDoc.data().role !== "manager" ||
    managerDoc.data().isActive !== true
  ) {
    throw new HttpsError(
      "permission-denied",
      "Only active managers can initialize inventory."
    );
  }

  const initializationRef = firestore
    .collection("inventory_meta")
    .doc("initialization");

  try {
    const result = await firestore.runTransaction(async (transaction) => {
      // 3. Prevent Re-initialization
      const initializationDoc = await transaction.get(initializationRef);

      if (initializationDoc.exists) {
        throw new HttpsError(
          "already-exists",
          "Inventory has already been initialized."
        );
      }

      // 4. Read Existing Products And Production Records
      const productsSnapshot = await transaction.get(
        firestore.collection("products")
      );

      const productionSnapshot = await transaction.get(
        firestore.collection("production_records")
      );

      // 5. Aggregate Production By Product
      const inventory = new Map();

      for (const productDoc of productsSnapshot.docs) {
        const product = productDoc.data();

        inventory.set(productDoc.id, {
          productId: productDoc.id,
          productName: product.name || "",
          totalProduced: 0,
          totalOutgoing: 0,
          availableQuantity: 0,
        });
      }

      for (const productionDoc of productionSnapshot.docs) {
        const production = productionDoc.data();

        if (!Array.isArray(production.items)) {
          continue;
        }

        for (const item of production.items) {
          const productId = item.productId;
          const quantity = item.quantity;

          if (
            typeof productId !== "string" ||
            !productId.trim() ||
            !Number.isSafeInteger(quantity) ||
            quantity <= 0
          ) {
            throw new HttpsError(
              "failed-precondition",
              `Invalid production item in record ${productionDoc.id}.`
            );
          }

          if (!inventory.has(productId)) {
            inventory.set(productId, {
              productId,
              productName: item.productName || "",
              totalProduced: 0,
              totalOutgoing: 0,
              availableQuantity: 0,
            });
          }

          const balance = inventory.get(productId);
          balance.totalProduced += quantity;

          if (!Number.isSafeInteger(balance.totalProduced)) {
            throw new HttpsError(
              "failed-precondition",
              "Production quantity is too large."
            );
          }
        }
      }

      // 6. Prepare Inventory Balances
      for (const balance of inventory.values()) {
        balance.availableQuantity =
          balance.totalProduced - balance.totalOutgoing;

        const balanceRef = firestore
          .collection("inventory_balances")
          .doc(balance.productId);

        transaction.set(balanceRef, {
          ...balance,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }

      // 7. Save Initialization Marker
      transaction.set(initializationRef, {
        initialized: true,
        initializedBy: managerUid,
        initializedAt: FieldValue.serverTimestamp(),
        productsCount: inventory.size,
        productionRecordsCount: productionSnapshot.size,
      });

      return {
        productsCount: inventory.size,
        productionRecordsCount: productionSnapshot.size,
      };
    });

    return {
      success: true,
      ...result,
      message: "Inventory initialized successfully.",
    };

  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Initialize Inventory Error:", error);

    throw new HttpsError(
      "internal",
      "Failed to initialize inventory."
    );
  }
});

// Create Production Record And Update Inventory
exports.createProductionRecord = onCall(async (request) => {
  // 1. Check Authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  const firestore = getFirestore();
  const actorUid = request.auth.uid;
  const data = request.data || {};

  // 2. Validate Basic Input
  const { workerId, date, items } = data;

  if (
    typeof workerId !== "string" ||
    !workerId.trim() ||
    typeof date !== "string" ||
    !Array.isArray(items) ||
    items.length === 0 ||
    items.length > 50
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide a valid workerId, date, and production items."
    );
  }

  const productionDate = new Date(date);

  if (Number.isNaN(productionDate.getTime())) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid production date."
    );
  }

  const targetWorkerId = workerId.trim();

  // 3. Validate Items And Reject Duplicate Products
  const productQuantities = new Map();

  for (const item of items) {
    if (
      !item ||
      typeof item.productId !== "string" ||
      !item.productId.trim() ||
      !Number.isSafeInteger(item.quantity) ||
      item.quantity <= 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Each item must have a valid productId and positive integer quantity."
      );
    }

    const productId = item.productId.trim();

    if (productQuantities.has(productId)) {
      throw new HttpsError(
        "invalid-argument",
        "Duplicate products are not allowed in the same production record."
      );
    }

    productQuantities.set(productId, item.quantity);
  }

  const userRef = firestore.collection("users").doc(actorUid);
  const workerRef = firestore.collection("users").doc(targetWorkerId);

  const initializationRef = firestore
    .collection("inventory_meta")
    .doc("initialization");

  const productionRef = firestore
    .collection("production_records")
    .doc();

  try {
    const result = await firestore.runTransaction(async (transaction) => {
      // 4. Read User And Initialization Data
      const userDoc = await transaction.get(userRef);
      const workerDoc = await transaction.get(workerRef);
      const initializationDoc = await transaction.get(initializationRef);

      if (!userDoc.exists || userDoc.data().isActive !== true) {
        throw new HttpsError(
          "permission-denied",
          "Your account is missing or inactive."
        );
      }

      const actor = userDoc.data();

      if (
        actor.role !== "manager" &&
        actor.role !== "worker"
      ) {
        throw new HttpsError(
          "permission-denied",
          "Invalid user role."
        );
      }

      if (!workerDoc.exists || workerDoc.data().isActive !== true) {
        throw new HttpsError(
          "not-found",
          "Active worker account not found."
        );
      }

      if (workerDoc.data().role !== "worker") {
        throw new HttpsError(
          "invalid-argument",
          "Production must belong to a worker account."
        );
      }

      // 5. Check Permissions
      if (
        actor.role === "worker" &&
        actorUid !== targetWorkerId
      ) {
        throw new HttpsError(
          "permission-denied",
          "Workers can only add their own production."
        );
      }

      if (
        actor.role === "manager" &&
        actor.isActive !== true
      ) {
        throw new HttpsError(
          "permission-denied",
          "Only active managers can add production."
        );
      }

      // 6. Make Sure Inventory Is Initialized
      if (
        !initializationDoc.exists ||
        initializationDoc.data().initialized !== true
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Inventory must be initialized before adding production."
        );
      }

      // 7. Read Products And Inventory Balances
      const preparedItems = [];

      for (const [productId, quantity] of productQuantities) {
        const productRef = firestore
          .collection("products")
          .doc(productId);

        const balanceRef = firestore
          .collection("inventory_balances")
          .doc(productId);

        const productDoc = await transaction.get(productRef);
        const balanceDoc = await transaction.get(balanceRef);

        if (!productDoc.exists) {
          throw new HttpsError(
            "not-found",
            `Product ${productId} was not found.`
          );
        }

        const product = productDoc.data();

        if (product.isActive !== true) {
          throw new HttpsError(
            "failed-precondition",
            `Product ${productId} is inactive.`
          );
        }

        const price = product.pricePerCarton;

        if (
          typeof price !== "number" ||
          !Number.isFinite(price) ||
          price < 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            `Invalid price for product ${productId}.`
          );
        }

        if (!balanceDoc.exists) {
          throw new HttpsError(
            "failed-precondition",
            `Inventory balance is missing for product ${productId}.`
          );
        }

        const balance = balanceDoc.data();

        if (
          !Number.isSafeInteger(balance.totalProduced) ||
          !Number.isSafeInteger(balance.totalOutgoing) ||
          !Number.isSafeInteger(balance.availableQuantity) ||
          balance.availableQuantity < 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            `Invalid inventory balance for product ${productId}.`
          );
        }

        const itemTotal = quantity * price;

        if (!Number.isFinite(itemTotal)) {
          throw new HttpsError(
            "invalid-argument",
            "Production amount is invalid."
          );
        }

        preparedItems.push({
          productId,
          productName: product.name,
          quantity,
          pricePerCarton: price,
          totalAmount: itemTotal,
          balanceRef,
          currentBalance: balance,
        });
      }

      // 8. Calculate Production Totals
      const totalCartons = preparedItems.reduce(
        (sum, item) => sum + item.quantity,
        0
      );

      const totalAmount = preparedItems.reduce(
        (sum, item) => sum + item.totalAmount,
        0
      );

      if (
        !Number.isSafeInteger(totalCartons) ||
        !Number.isFinite(totalAmount)
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Production totals are invalid."
        );
      }

      // 9. Update Inventory Balances
      for (const item of preparedItems) {
        const newTotalProduced =
          item.currentBalance.totalProduced + item.quantity;

        const newAvailableQuantity =
          item.currentBalance.availableQuantity + item.quantity;

        if (
          !Number.isSafeInteger(newTotalProduced) ||
          !Number.isSafeInteger(newAvailableQuantity)
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Inventory quantity is too large."
          );
        }

        transaction.update(item.balanceRef, {
          productName: item.productName,
          totalProduced: newTotalProduced,
          availableQuantity: newAvailableQuantity,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }

      // 10. Save Production Record
      transaction.set(productionRef, {
        workerId: targetWorkerId,
        workerName: workerDoc.data().name,
        date: Timestamp.fromDate(productionDate),
        items: preparedItems.map((item) => ({
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          pricePerCarton: item.pricePerCarton,
          totalAmount: item.totalAmount,
        })),
        totalCartons,
        totalAmount,
        createdAt: FieldValue.serverTimestamp(),
        createdBy: actorUid,
      });

      return {
        productionId: productionRef.id,
        totalCartons,
        totalAmount,
      };
    });

    return {
      success: true,
      ...result,
      message: "Production recorded successfully.",
    };

  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Create Production Error:", error);

    throw new HttpsError(
      "internal",
      "Failed to create production record."
    );
  }
});


// Create Outgoing Record And Deduct Inventory

exports.createOutgoingRecord = onCall(async (request) => {
  // 1. Check Authentication
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  const firestore = getFirestore();
  const managerUid = request.auth.uid;
  const data = request.data || {};

  // 2. Validate Basic Input
  const {
    date,
    deliveredBy,
    receivedBy,
    direction,
    items,
  } = data;

  if (
    typeof date !== "string" ||
    typeof deliveredBy !== "string" ||
    !deliveredBy.trim() ||
    typeof receivedBy !== "string" ||
    !receivedBy.trim() ||
    typeof direction !== "string" ||
    !direction.trim() ||
    !Array.isArray(items) ||
    items.length === 0 ||
    items.length > 50
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide valid outgoing record details."
    );
  }

  const outgoingDate = new Date(date);

  if (Number.isNaN(outgoingDate.getTime())) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid outgoing date."
    );
  }

  // 3. Validate Items And Reject Duplicate Products
  const productItems = new Map();

  for (const item of items) {
    if (
      !item ||
      typeof item.productId !== "string" ||
      !item.productId.trim() ||
      !Number.isSafeInteger(item.quantity) ||
      item.quantity <= 0 ||
      typeof item.orderAmount !== "number" ||
      !Number.isFinite(item.orderAmount) ||
      item.orderAmount <= 0 ||
      item.orderAmount > Number.MAX_SAFE_INTEGER / 100
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Each item must have a valid productId, positive quantity, and valid order amount."
      );
    }

    const productId = item.productId.trim();

    if (productItems.has(productId)) {
      throw new HttpsError(
        "invalid-argument",
        "Duplicate products are not allowed in the same outgoing record."
      );
    }

    productItems.set(productId, {
      quantity: item.quantity,
      orderAmount: item.orderAmount,
    });
  }

  // 4. Prepare References
  const managerRef = firestore
    .collection("users")
    .doc(managerUid);

  const initializationRef = firestore
    .collection("inventory_meta")
    .doc("initialization");

  const counterRef = firestore
    .collection("outgoing_meta")
    .doc("counter");

  const outgoingRef = firestore
    .collection("outgoing_records")
    .doc();

  try {
    const result = await firestore.runTransaction(async (transaction) => {
      // 5. Read Manager, Initialization And Counter
      const managerDoc = await transaction.get(managerRef);
      const initializationDoc = await transaction.get(initializationRef);
      const counterDoc = await transaction.get(counterRef);

      if (
        !managerDoc.exists ||
        managerDoc.data().role !== "manager" ||
        managerDoc.data().isActive !== true
      ) {
        throw new HttpsError(
          "permission-denied",
          "Only active managers can create outgoing records."
        );
      }

      if (
        !initializationDoc.exists ||
        initializationDoc.data().initialized !== true
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Inventory must be initialized first."
        );
      }

      const currentCounter = counterDoc.exists
        ? counterDoc.data().lastNumber
        : 0;

      if (
        !Number.isSafeInteger(currentCounter) ||
        currentCounter < 0 ||
        currentCounter >= Number.MAX_SAFE_INTEGER
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Outgoing record counter is invalid."
        );
      }

      const nextNumber = currentCounter + 1;
      const recordNumber = `OUT-${String(nextNumber).padStart(6, "0")}`;

      // 6. Read Products And Inventory Balances
      const preparedItems = [];

      for (const [productId, itemData] of productItems) {
        const { quantity, orderAmount } = itemData;

        const productRef = firestore
          .collection("products")
          .doc(productId);

        const balanceRef = firestore
          .collection("inventory_balances")
          .doc(productId);

        const productDoc = await transaction.get(productRef);
        const balanceDoc = await transaction.get(balanceRef);

        if (!productDoc.exists) {
          throw new HttpsError(
            "not-found",
            `Product ${productId} was not found.`
          );
        }

        const product = productDoc.data();

        if (product.isActive !== true) {
          throw new HttpsError(
            "failed-precondition",
            `Product ${productId} is inactive.`
          );
        }

        if (
          typeof product.name !== "string" ||
          !product.name.trim()
        ) {
          throw new HttpsError(
            "failed-precondition",
            `Invalid product name for ${productId}.`
          );
        }

        if (!balanceDoc.exists) {
          throw new HttpsError(
            "failed-precondition",
            `Inventory balance is missing for product ${productId}.`
          );
        }

        const balance = balanceDoc.data();

        if (
          !Number.isSafeInteger(balance.totalProduced) ||
          !Number.isSafeInteger(balance.totalOutgoing) ||
          !Number.isSafeInteger(balance.availableQuantity) ||
          balance.totalProduced < 0 ||
          balance.totalOutgoing < 0 ||
          balance.availableQuantity < 0 ||
          balance.availableQuantity !==
            balance.totalProduced - balance.totalOutgoing
        ) {
          throw new HttpsError(
            "failed-precondition",
            `Invalid inventory balance for product ${productId}.`
          );
        }

        // 7. Check Available Quantity
        if (balance.availableQuantity < quantity) {
          throw new HttpsError(
            "failed-precondition",
            `Insufficient stock for ${product.name}. Available: ${balance.availableQuantity}, requested: ${quantity}.`
          );
        }

        // orderAmount is the manually entered total price
        // for this product, NOT price per carton.
        preparedItems.push({
          productId,
          productName: product.name,
          quantity,
          orderAmount,
          balanceRef,
          currentBalance: balance,
        });
      }

      // 8. Calculate Record Totals
      const totalCartons = preparedItems.reduce(
        (sum, item) => sum + item.quantity,
        0
      );

      const totalAmount = Math.round(
        preparedItems.reduce(
          (sum, item) => sum + item.orderAmount,
          0
        ) * 100
      ) / 100;

      if (
        !Number.isSafeInteger(totalCartons) ||
        !Number.isFinite(totalAmount) ||
        totalAmount <= 0 ||
        totalAmount > Number.MAX_SAFE_INTEGER / 100
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Outgoing totals are invalid."
        );
      }

      // 9. Update Inventory Balances
      for (const item of preparedItems) {
        const newTotalOutgoing =
          item.currentBalance.totalOutgoing + item.quantity;

        const newAvailableQuantity =
          item.currentBalance.availableQuantity - item.quantity;

        if (
          !Number.isSafeInteger(newTotalOutgoing) ||
          !Number.isSafeInteger(newAvailableQuantity) ||
          newAvailableQuantity < 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Inventory quantity is invalid."
          );
        }

        transaction.update(item.balanceRef, {
          totalOutgoing: newTotalOutgoing,
          availableQuantity: newAvailableQuantity,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }

      // 10. Update Outgoing Counter
      transaction.set(counterRef, {
        lastNumber: nextNumber,
        updatedAt: FieldValue.serverTimestamp(),
      });

      // 11. Save Outgoing Record
      transaction.set(outgoingRef, {
        recordNumber,
        date: Timestamp.fromDate(outgoingDate),
        deliveredBy: deliveredBy.trim(),
        receivedBy: receivedBy.trim(),
        direction: direction.trim(),

        items: preparedItems.map((item) => ({
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          orderAmount: item.orderAmount,
        })),

        totalCartons,
        totalAmount,

        createdAt: FieldValue.serverTimestamp(),
        createdBy: managerUid,
      });

      return {
        recordId: outgoingRef.id,
        recordNumber,
        totalCartons,
        totalAmount,
      };
    });

    return {
      success: true,
      ...result,
      message: "Outgoing record created successfully.",
    };

  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("Create Outgoing Error:", error);

    throw new HttpsError(
      "internal",
      "Failed to create outgoing record."
    );
  }
});
