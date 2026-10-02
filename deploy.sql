USE DATABASE PREDMACC_DB;
USE SCHEMA APP;

CREATE SERVICE IF NOT EXISTS PREDMACC_SERVICE
  IN COMPUTE POOL PREDMACC_POOL
  FROM SPECIFICATION $$
spec:
  containers:
  - name: predmacc
    image: /predmacc_db/app/predmacc_repo/predmacc:latest
    env:
      PORT: "8080"
    resources:
      requests:
        memory: 1Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: 1000m
    readinessProbe:
      port: 8080
      path: /api/health
  endpoints:
  - name: predmacc-endpoint
    port: 8080
    public: true
$$
  MIN_INSTANCES = 1
  MAX_INSTANCES = 1;

ALTER SERVICE PREDMACC_SERVICE FROM SPECIFICATION $$
spec:
  containers:
  - name: predmacc
    image: /predmacc_db/app/predmacc_repo/predmacc:latest
    env:
      PORT: "8080"
    resources:
      requests:
        memory: 1Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: 1000m
    readinessProbe:
      port: 8080
      path: /api/health
  endpoints:
  - name: predmacc-endpoint
    port: 8080
    public: true
$$;

SHOW ENDPOINTS IN SERVICE PREDMACC_SERVICE;
