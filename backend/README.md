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
