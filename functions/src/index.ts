import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// Medicines API
export const getMedicines = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const { firstAidKitId } = data;
  const medicinesRef = db.collection('medicines')
    .where('firstAidKitId', '==', firstAidKitId);
    
  const snapshot = await medicinesRef.get();
  return snapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));
});

export const createMedicine = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const { firstAidKitId, medicine } = data;
  const medicineRef = await db.collection('medicines').add({
    ...medicine,
    firstAidKitId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: context.auth.uid,
  });

  const doc = await medicineRef.get();
  return { id: doc.id, ...doc.data() };
});

// First Aid Kits API
export const createFirstAidKit = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const kitData = {
    ...data,
    users: {
      [context.auth.uid]: 'owner'
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const kitRef = await db.collection('first_aid_kits').add(kitData);
  const doc = await kitRef.get();
  return { id: doc.id, ...doc.data() };
});

// Sharing API
export const shareFirstAidKit = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const { firstAidKitId, userEmail, role } = data;
  
  // Найти пользователя по email
  const userSnapshot = await db.collection('users')
    .where('email', '==', userEmail)
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const userId = userSnapshot.docs[0].id;
  
  // Обновить права доступа
  await db.collection('first_aid_kits').doc(firstAidKitId).update({
    [`users.${userId}`]: role,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

// Notifications
export const checkExpiringMedicines = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async () => {
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);

    const snapshot = await db.collection('medicines')
      .where('expirationDate', '<=', thirtyDaysFromNow)
      .get();

    for (const doc of snapshot.docs) {
      const medicine = doc.data();
      const kitDoc = await db.collection('first_aid_kits')
        .doc(medicine.firstAidKitId)
        .get();
      
      const kit = kitDoc.data();
      if (!kit) continue;

      // Отправить уведомления всем пользователям аптечки
      for (const userId of Object.keys(kit.users)) {
        await db.collection('notifications').add({
          userId,
          type: 'expiring_medicine',
          medicineId: doc.id,
          medicineName: medicine.name,
          expirationDate: medicine.expirationDate,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
      }
    }
});

// Triggers
export const onMedicineUpdate = functions.firestore
  .document('medicines/{medicineId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    // Проверка низкого запаса
    if (newData.remainingQuantity < newData.lowStockThreshold && 
        oldData.remainingQuantity >= oldData.lowStockThreshold) {
      const kitDoc = await db.collection('first_aid_kits')
        .doc(newData.firstAidKitId)
        .get();
      
      const kit = kitDoc.data();
      if (!kit) return;

      // Отправить уведомления о низком запасе
      for (const userId of Object.keys(kit.users)) {
        await db.collection('notifications').add({
          userId,
          type: 'low_stock',
          medicineId: context.params.medicineId,
          medicineName: newData.name,
          quantity: newData.remainingQuantity,
          unit: newData.unit,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
      }
    }
}); 