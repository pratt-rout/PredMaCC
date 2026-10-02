# PredMaCC

A full-stack web application with a React frontend and a FastAPI backend, containerized and deployed to Snowpark Container Services (SPCS) via a GitHub Actions CI/CD pipeline.

## Architecture

Frontend and backend run together in a single Docker container:

- **React (Vite)** — static frontend, built and served by **nginx**
- **FastAPI** — backend API, served by **uvicorn**
- **nginx** serves the built React app and proxies `/api/*` requests to the FastAPI process
- **supervisord** runs both nginx and uvicorn as the container's single entrypoint
- The container listens on port `8080` and is deployed as a public SPCS service endpoint

```
Browser → nginx (port 8080)
            ├── / → React static files
            └── /api/* → uvicorn (FastAPI, 127.0.0.1:8000)
```

## Current functionality

### Backend (FastAPI)
- `GET /api/health` — health check endpoint, used by the SPCS readiness probe
- `GET /api/hello` — returns a greeting message
- `POST /api/echo` — accepts `{"message": "..."}` and echoes it back

### Frontend (React + Vite)
- Fetches `/api/hello` on load and displays the backend's response
- Text input + button that calls `/api/echo` and displays the result

### Deployment (SPCS)
- Multi-stage `Dockerfile`: builds the React app, then packages it with the FastAPI backend, nginx, and supervisord into a single runtime image
- `service-spec.yaml` — SPCS service specification (container, resources, readiness probe, public endpoint)
- `deploy.sql` — creates or updates the SPCS service (`CREATE SERVICE IF NOT EXISTS` + `ALTER SERVICE ... FROM SPECIFICATION`)

### CI/CD (GitHub Actions)
- `.github/workflows/deploy-spcs.yml` runs on every push to `main`:
  1. Checks out the repo
  2. Authenticates to Snowflake via OIDC (workload identity federation, no stored secrets)
  3. Logs in to the Snowflake image registry
  4. Builds and pushes the Docker image
  5. Runs `deploy.sql` to create/update the SPCS service

## Project structure

```
PredMaCC/
├── backend/
│   ├── app/main.py          # FastAPI app and routes
│   └── requirements.txt
├── frontend/
│   ├── src/App.jsx          # Main React component
│   ├── src/main.jsx
│   └── vite.config.js
├── nginx.conf                # Static file serving + /api proxy
├── supervisord.conf           # Runs nginx + uvicorn together
├── Dockerfile                 # Multi-stage build (frontend build -> runtime image)
├── service-spec.yaml          # SPCS service specification
├── deploy.sql                 # SPCS CREATE/ALTER SERVICE
└── .github/workflows/deploy-spcs.yml
```

## Local development

**Backend:**
```
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

**Frontend:**
```
cd frontend
npm install
npm run dev
```
The Vite dev server proxies `/api` requests to `http://localhost:8000`.

**Full container (requires Docker):**
```
docker build --platform linux/amd64 -t predmacc:latest .
docker run -p 8080:8080 predmacc:latest
```

## Deployment

Deployment to SPCS is automated via GitHub Actions on push to `main`. Required one-time Snowflake setup (already configured for this project):

- Database/schema: `PREDMACC_DB.APP`
- Image repository: `PREDMACC_DB.APP.PREDMACC_REPO`
- Compute pool: `PREDMACC_POOL`
- Service user `SVC_GITHUB_ACTIONS` with OIDC workload identity trusting this repository
- Role `CI_SPCS_DEPLOY_ROLE` granting the service user least-privilege access to deploy

After a successful deploy, the public endpoint URL can be retrieved with:
```sql
SHOW ENDPOINTS IN SERVICE PREDMACC_DB.APP.PREDMACC_SERVICE;
```
