# Postgres + Postgrest
Basic example of initialising ```PostGres``` ```pgAdmin```, ```PostgREST``` and ```Swagger``` with docker compose on ubuntu.

## 1. Download & Install Docker Desktop

https://docs.docker.com/desktop/install/ubuntu/

## 2. clone repository
!! To clone the repo AND submodules use the ```--recursive``` flag !!
```
git clone --recursive https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker.git
```

## 2. Change credentials
**Copy** the ```_.env``` file to ```.env``` and change the credentials.

## 3. Run in Background

```bash
docker compose up -d
```

**Potgrest**
http://localhost:3000/

**Swagger**
http://localhost:4080/

**PgAdmin**
http://localhost:5050/pgadmin/


## 4. Stop & Remove

```bash
docker compose down --volumes
```

### ERROR
#### If "The CSRF session token is missing." error occures
Close pgadmin session in browser tab and retry.