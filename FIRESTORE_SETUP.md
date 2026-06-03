# STM App Firestore Setup

This project now supports saving backend data to Cloud Firestore.

## What is stored in Firestore

The backend saves these collections:

- `users`
- `units`
- `enrollments`
- `tasks`
- `groups`
- `groupMessages`
- `notifications`
- `studySessions`

## 1. Enable Firestore in Firebase

Firebase Console → Build → Firestore Database → Create database.

Use test mode for the demo if needed.

## 2. Create role users

Create a `users` collection with these documents:

### Document ID: `admin@test.com`
- `email`: string → `admin@test.com`
- `name`: string → `Admin User`
- `role`: string → `admin`

### Document ID: `lecturer@test.com`
- `email`: string → `lecturer@test.com`
- `name`: string → `Lecturer User`
- `role`: string → `lecturer`

### Document ID: `student@test.com`
- `email`: string → `student@test.com`
- `name`: string → `Student User`
- `role`: string → `student`

## 3. Download service account key

Firebase Console → Project settings → Service accounts → Generate new private key.

Rename the downloaded file to:

```text
serviceAccountKey.json
```

Place it here:

```text
backend/serviceAccountKey.json
```

Do not upload this file to GitHub.

## 4. Test Firestore locally

From the backend folder:

```powershell
cd C:\FlutterProjects\stm_app_fresh\backend
& "C:\Program Files\nodejs\npm.cmd" install
& "C:\Program Files\nodejs\node.exe" firestore_test.js
```

If it works, Firebase Console should show:

```text
test / connection_check
```

## 5. Run with Docker

From the project root:

```powershell
cd C:\FlutterProjects\stm_app_fresh
docker compose down --rmi local --volumes --remove-orphans
docker builder prune -f
docker compose build --no-cache
docker compose up
```

Open:

```text
http://localhost:8080
```

Backend check:

```text
http://localhost:5000/api/health
```

The health response should show:

```json
{"status":"ok","port":5000,"firestoreEnabled":true}
```

If `firestoreEnabled` is false, the backend cannot find or read `backend/serviceAccountKey.json`.

---

## 6. Firestore security rules

When moving out of test mode, apply these rules in Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read their own document.
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.token.email == userId;
      allow write: if false;
    }

    // Authenticated users can read units and enrollments.
    match /units/{unitId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    match /enrollments/{enrollmentId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Tasks are readable by authenticated users.
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Group messages readable by authenticated users.
    match /groupMessages/{messageId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // All other writes go through the backend service account only.
  }
}
```

The backend uses the service account key and bypasses these rules. These rules only apply to direct client access.

---

## 7. Troubleshooting Firestore

### `firestoreEnabled: false` in health check

- Check that `backend/serviceAccountKey.json` exists and is not empty.
- Make sure the file belongs to the correct Firebase project.
- Rebuild the Docker containers after placing the key:

```powershell
docker compose down
docker compose up --build
```

### Permission denied errors in backend logs

- Verify the service account has the **Cloud Datastore User** role in Google Cloud Console → IAM.

### Data not appearing in Firebase Console

- Firestore may take a few seconds to show new documents.
- Check the backend logs for write errors:

```powershell
docker compose logs backend
```
