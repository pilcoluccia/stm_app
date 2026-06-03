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
