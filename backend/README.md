# STM App Backend

Run the backend from this folder:

```powershell
& "C:\Program Files\nodejs\npm.cmd" install
& "C:\Program Files\nodejs\node.exe" server.js
```

The API runs at:

```text
http://localhost:5000/api
```

Health check:

```text
http://localhost:5000/api/health
```

Docker option:

```powershell
docker build -t stm-backend .
docker run -p 5000:5000 stm-backend
```

## TANDI — Tasks & Progress Service

This backend also implements the Tasks & Progress Service endpoints:

- `GET /api/tasks?unitId=X&studentId=Y` — filter homework/tasks by unit and/or student.
- `POST /api/task` — create homework.
- `PUT /api/tasks/:id` — edit homework details.
- `PUT /api/tasks/:id/status` — change status (`ToDo`, `InProgress`, or `Done`; also accepts `To Do` and `In Progress`).
- `DELETE /api/tasks/:id` — delete homework.
- `GET /api/progress/:studentId/:unitId` — calculate total hours, completed hours, remaining hours, and progress percentage.

The existing plural task routes are kept so the current Flutter screens continue working.
