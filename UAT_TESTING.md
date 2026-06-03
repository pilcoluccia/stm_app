# STM App — UAT Testing Guide

User Acceptance Testing checklist for the final merged main branch.

Run all tests after every branch has been merged into main.

---

## How to run the app for testing

### Option A — Docker (recommended for final testing)

```powershell
cd "d:\Proyectos\Lucia\Nueva carpeta\stm_app\stm_app"
docker compose up --build
```

Open the app at:

```
http://localhost:8080
```

Backend health check:

```
http://localhost:5000/api/health
```

### Option B — Flutter Web (for quick testing during development)

```powershell
flutter run -d chrome
```

---

## Test accounts

| Role     | Email               | Password   |
|----------|---------------------|------------|
| Admin    | admin@test.com      | Test1234!  |
| Lecturer | lecturer@test.com   | Test1234!  |
| Student  | student@test.com    | Test1234!  |

---

## 1. Authentication

### TC-01 — Admin login

**Steps:**
1. Open the app.
2. Enter `admin@test.com` and the password.
3. Press Login.

**Expected:** App opens the Admin dashboard.

**Pass / Fail:** ___

---

### TC-02 — Lecturer login

**Steps:**
1. Open the app.
2. Enter `lecturer@test.com` and the password.
3. Press Login.

**Expected:** App opens the Lecturer dashboard.

**Pass / Fail:** ___

---

### TC-03 — Student login

**Steps:**
1. Open the app.
2. Enter `student@test.com` and the password.
3. Press Login.

**Expected:** App opens the Student dashboard.

**Pass / Fail:** ___

---

### TC-04 — Google Sign-In (web only)

**Steps:**
1. Open the app in Chrome.
2. Press the Google Sign-In button.
3. Select a Google account.

**Expected:** App logs in and shows the correct dashboard for that account's role.

**Pass / Fail:** ___

---

### TC-05 — Logout

**Steps:**
1. Log in with any account.
2. Go to Profile.
3. Press Logout.

**Expected:** App returns to the login screen.

**Pass / Fail:** ___

---

## 2. Admin — Units

### TC-06 — Create a unit

**Steps:**
1. Log in as Admin.
2. Go to Units.
3. Press Add Unit.
4. Fill in unit name and details.
5. Save.

**Expected:** New unit appears in the units list.

**Pass / Fail:** ___

---

### TC-07 — Assign a lecturer to a unit

**Steps:**
1. Log in as Admin.
2. Open a unit.
3. Assign a lecturer from the list.
4. Save.

**Expected:** Lecturer is shown as assigned to that unit.

**Pass / Fail:** ___

---

## 3. Enrollment

### TC-08 — Student enrols in a unit

**Steps:**
1. Log in as Student.
2. Go to Units / Browse.
3. Select a unit.
4. Press Enrol.

**Expected:** Unit appears in the student's enrolled units list.

**Pass / Fail:** ___

---

## 4. Tasks

### TC-09 — Lecturer creates a task

**Steps:**
1. Log in as Lecturer.
2. Go to Tasks.
3. Press Add Task.
4. Fill in title, description, due date, and priority.
5. Save.

**Expected:** Task appears in the task list.

**Pass / Fail:** ___

---

### TC-10 — Assign task to a selected student

**Steps:**
1. Log in as Lecturer.
2. Open an existing task.
3. Select a specific student to assign the task to.
4. Save.

**Expected:** Task is visible to that student when they log in.

**Pass / Fail:** ___

---

### TC-11 — Student marks a task as complete

**Steps:**
1. Log in as Student.
2. Open an assigned task.
3. Mark it as complete.

**Expected:** Task status changes to complete. Progress updates in the dashboard.

**Pass / Fail:** ___

---

## 5. Group Tasks and Chat

### TC-12 — Create a group task

**Steps:**
1. Log in as Lecturer.
2. Go to Group Tasks.
3. Create a new group task and assign it to a group.

**Expected:** Group task appears for all members of that group.

**Pass / Fail:** ___

---

### TC-13 — Group chat message

**Steps:**
1. Log in as Student.
2. Open a group chat linked to a task.
3. Send a message.

**Expected:** Message appears in the chat for all group members.

**Pass / Fail:** ___

---

## 6. Notifications

### TC-14 — Notification appears after task assignment

**Steps:**
1. Log in as Lecturer and assign a task to a student.
2. Log out.
3. Log in as that Student.
4. Check the Notifications section.

**Expected:** A notification about the new task assignment is visible.

**Pass / Fail:** ___

---

## 7. Firestore Persistence

### TC-15 — Data persists after restart

**Steps:**
1. Log in, create a task or unit.
2. Stop the app (`Ctrl + C` then `docker compose down`).
3. Start the app again (`docker compose up`).
4. Log in with the same account.

**Expected:** Previously created data is still visible.

**Pass / Fail:** ___

---

### TC-16 — Backend health check shows Firestore enabled

**Steps:**
1. Run the app with Docker.
2. Open in browser: `http://localhost:5000/api/health`

**Expected result:**

```json
{"status":"ok","port":5000,"firestoreEnabled":true}
```

If `firestoreEnabled` is `false`, check that `backend/serviceAccountKey.json` is present.

**Pass / Fail:** ___

---

## 8. Docker Run

### TC-17 — Full Docker build and run

**Steps:**
1. Open PowerShell in the project root.
2. Run:

```powershell
docker compose up --build
```

3. Wait for both containers to start.
4. Open `http://localhost:8080`.

**Expected:** App loads in the browser. No build errors in the terminal.

**Pass / Fail:** ___

---

### TC-18 — Stop and restart without data loss

**Steps:**
1. Press `Ctrl + C` to stop.
2. Run `docker compose down`.
3. Run `docker compose up` (without `--build`).
4. Open `http://localhost:8080`.

**Expected:** App loads correctly. Existing data is still present.

**Pass / Fail:** ___

---

## Test summary

| Test | Description                              | Pass / Fail |
|------|------------------------------------------|-------------|
| TC-01 | Admin login                             |             |
| TC-02 | Lecturer login                          |             |
| TC-03 | Student login                           |             |
| TC-04 | Google Sign-In                          |             |
| TC-05 | Logout                                  |             |
| TC-06 | Create a unit                           |             |
| TC-07 | Assign lecturer to unit                 |             |
| TC-08 | Student enrolment                       |             |
| TC-09 | Lecturer creates a task                 |             |
| TC-10 | Assign task to selected student         |             |
| TC-11 | Student marks task complete             |             |
| TC-12 | Create group task                       |             |
| TC-13 | Group chat message                      |             |
| TC-14 | Notification after task assignment      |             |
| TC-15 | Data persists after restart             |             |
| TC-16 | Firestore enabled in health check       |             |
| TC-17 | Full Docker build and run               |             |
| TC-18 | Stop and restart without data loss      |             |

---

## Notes

Write any issues or observations here during testing:

-
