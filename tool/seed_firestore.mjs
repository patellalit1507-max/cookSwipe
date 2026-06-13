// Seeds the Firestore `foodItems` collection from assets/data/food_dataset.json.
//
// Setup (one time):
//   1. Firebase console → Project settings → Service accounts
//      → "Generate new private key" → save as tool/serviceAccountKey.json
//      (this file is gitignored — never commit it).
//   2. npm install firebase-admin
//
// Run from the project root:
//   node tool/seed_firestore.mjs
//
// Re-running is safe: documents are written by id (upsert).

import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const serviceAccount = JSON.parse(
  readFileSync(new URL('./serviceAccountKey.json', import.meta.url), 'utf8'),
);
const dataset = JSON.parse(
  readFileSync(new URL('../assets/data/food_dataset.json', import.meta.url), 'utf8'),
);

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const BATCH_LIMIT = 500;
let written = 0;

for (let i = 0; i < dataset.length; i += BATCH_LIMIT) {
  const batch = db.batch();
  for (const item of dataset.slice(i, i + BATCH_LIMIT)) {
    batch.set(db.collection('foodItems').doc(item.id), item);
  }
  await batch.commit();
  written += Math.min(BATCH_LIMIT, dataset.length - i);
  console.log(`Seeded ${written}/${dataset.length} dishes…`);
}

console.log(`Done. ${written} food items in Firestore.`);
