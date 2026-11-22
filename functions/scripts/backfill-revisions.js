// Adds revision 1 and updatedAt to orders placed before revisions existed.
// The Preparation system rejects an order without a revision.
//
// Usage, from the functions folder:
//   node scripts/backfill-revisions.js <projectId>          (dry run)
//   node scripts/backfill-revisions.js <projectId> --write
//
// It needs Google credentials with access to the project, for example
// GOOGLE_APPLICATION_CREDENTIALS or "gcloud auth application-default login".
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

async function main() {
  const [projectId, flag] = process.argv.slice(2);
  if (!projectId) {
    console.error("Usage: node scripts/backfill-revisions.js <projectId> [--write]");
    process.exitCode = 1;
    return;
  }
  initializeApp({projectId});
  const db = getFirestore();
  const snapshot = await db.collection("orders").get();
  const missing = snapshot.docs.filter(
      (doc) => !Number.isInteger(doc.get("revision")),
  );
  console.log(`${missing.length} of ${snapshot.size} orders have no revision.`);
  if (flag !== "--write") {
    console.log("Dry run. Add --write to update them.");
    return;
  }

  let failed = 0;
  const writer = db.bulkWriter();
  writer.onWriteError((error) => {
    failed++;
    console.error(`${error.documentRef.id}: ${error.message}`);
    return false;
  });
  for (const doc of missing) {
    // The precondition skips an order that changed since it was read.
    writer.update(
        doc.ref,
        {revision: 1, updatedAt: doc.updateTime},
        {lastUpdateTime: doc.updateTime},
    );
  }
  await writer.close();
  console.log(`Updated ${missing.length - failed}. Failed ${failed}.`);
  if (failed > 0) process.exitCode = 1;
}

main();
