const admin = require('firebase-admin');
const fs = require('fs');

// Replace with the path to your service account key
const serviceAccount = require('C:/Users/HP/Desktop/inv-puskesmas-firebase-adminsdk-e5qcn-e6e1312666.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();

async function exportUsers() {
  const allUsers = [];
  let nextPageToken;

  do {
    const listUsersResult = await auth.listUsers(1000, nextPageToken);
    listUsersResult.users.forEach((userRecord) => {
      allUsers.push(userRecord.toJSON());
    });
    nextPageToken = listUsersResult.pageToken;
  } while (nextPageToken);

  fs.writeFileSync('users.json', JSON.stringify(allUsers, null, 2));
  console.log('User data exported to users.json');
}

exportUsers().catch(console.error);
