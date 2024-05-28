# Postgres + Postgrest
Basic example of initialising ```PostGres``` ```pgAdmin```, ```PostgREST``` and ```Swagger``` with docker compose on ubuntu.

## 1. Download & Install Docker Desktop

https://docs.docker.com/desktop/install/ubuntu/

## 2. Change credentials
Copy the ```_.env.dev``` file to ```.env``` and change the credentials.

## 3. Run in Background

```bash
docker compose up -d
```

### Potgrest
http://localhost:3000/

### Swagger
http://localhost:4080/

### PgAdmin
http://localhost:5050/pgadmin/


## 4. Stop
```bash
docker compose down --volumes
```

### ERROR: The CSRF session token is missing.
Close pgadmin session in browser tab and retry.