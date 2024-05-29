# Postgres + Postgrest
Basic example of initialising ```PostGres``` ```pgAdmin```, ```PostgREST``` and ```Swagger``` with docker compose on ubuntu.

## 1. Download & Install Docker Desktop

https://docs.docker.com/desktop/install/ubuntu/

and

https://nodejs.org/

## 2. clone repository
!! To clone the repo AND submodules use the ```--recursive``` flag !!
```
git clone https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker.git
```

<sub>For employees of the Thünen Institute:</sub>
```
git clone --recursive https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker.git
```

## 3. Change credentials
**Copy** the ```_.env``` file to ```.env``` and change the credentials for production.


## 4. Run

```bash
docker compose up
```
<sub>To run docker in background mode add ```-d```</sub>

**Potgrest**
http://localhost:3000/

**Swagger**
http://localhost:4080/

**PgAdmin**
http://localhost:5050/pgadmin/


## 5. Stop & Remove

```bash
docker compose down --volumes
```

## SETUP pgAdmin
Add a connection to postGres by register a new Server. Add Host name (```PGADMIN_HOST_NAME```), username (```POSTGRES_USER```) and password (```POSTGRES_PASSWORD```) defined in your ```.env``` file.

![image](https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker/assets/11278402/a0d44a13-6dea-4071-928c-26f0c7ccc4fb)


#### If "The CSRF session token is missing." error occures
Close pgadmin session in browser tab and retry.
