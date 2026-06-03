# STM App Docker Setup

This project has two parts:

- **Frontend:** Flutter Web served by Nginx
- **Backend:** Node.js/Express API

Docker Compose runs both together.

## 1. Requirements

Install and open **Docker Desktop** first.

Then check Docker in PowerShell:

```powershell
docker --version
docker compose version
```

Both commands should show version numbers.

## 2. Run the project

Open PowerShell in the main project folder, for example:

```powershell
cd C:\FlutterProjects\stm_app_fresh
```

Then run:

```powershell
docker compose up --build
```

The first build can take several minutes because Docker downloads Node, Flutter, and Nginx images.

## 3. Open the app

Frontend:

```text
http://localhost:8080
```

Backend health check:

```text
http://localhost:5000/api/health
```

A correct backend response looks like:

```json
{"status":"ok","port":5000}
```

## 4. Stop the project

In the terminal running Docker, press:

```text
Ctrl + C
```

Then run:

```powershell
docker compose down
```

## 5. Run again later

If no code changed:

```powershell
docker compose up
```

If code changed:

```powershell
docker compose up --build
```

If Docker seems to use an old backend image, rebuild without cache:

```powershell
docker compose build --no-cache backend
docker compose up --build
```

## 6. Firebase / Google Sign-In note

Docker uses this frontend URL:

```text
http://localhost:8080
```

Add it in Google Cloud Console under the Web OAuth Client:

```text
Authorized JavaScript origins:
http://localhost:8080
```

Keep the normal Flutter URL too if you still use `flutter run`:

```text
http://localhost:57057
```

## 7. Data note

The backend data folder is mounted to a Docker volume:

```yaml
stm_backend_data:/app/data
```

This means backend data can persist after restarting containers. To remove all Docker-stored backend data, run:

```powershell
docker compose down -v
```

Only use `-v` if you intentionally want to reset Docker volume data.

---

## 8. Troubleshooting

### Port already in use

If you see an error like `port is already allocated`, another process is using port 5000 or 8080.

Find and stop the process, or change the port in `docker-compose.yml`:

```yaml
ports:
  - "5001:5000"   # change left number only
```

---

### Backend container keeps restarting

Check the backend logs:

```powershell
docker compose logs backend
```

The most common cause is a missing or invalid `backend/serviceAccountKey.json`. Place the correct file and rebuild:

```powershell
docker compose up --build
```

---

### Frontend shows a blank page or old version

Force a full rebuild without cache:

```powershell
docker compose down
docker compose build --no-cache
docker compose up
```

---

### Google Sign-In fails in Docker

Make sure `http://localhost:8080` is added as an **Authorized JavaScript origin** in Google Cloud Console under the OAuth 2.0 client for this project.

---

### Check container status

```powershell
docker compose ps
```

Both `stm_backend` and `stm_frontend` should show status `running` or `healthy`.
