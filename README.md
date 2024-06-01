[![Docker Compose Actions Workflow](https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker/actions/workflows/test.yml/badge.svg)](https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker/actions/workflows/test.yml)

# Postgres + Postgrest
This repository containes required software to run the backend for the TFM project.

Terrestrial Forest Monitor (TFM) [Frontend](https://github.com/Thuenen-Forest-Ecosystems/terrestrial-forest-monitor)

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


## Test
```bash
docker compose --env-file ./_.env up
npm test
```


## Setup pgAdmin
Add a connection to postGres by register a new Server. Add Host name (```PGADMIN_HOST_NAME```), username (```POSTGRES_USER```) and password (```POSTGRES_PASSWORD```) defined in your ```.env``` file.

![image](https://github.com/Thuenen-Forest-Ecosystems/TFM-postgres-docker/assets/11278402/a0d44a13-6dea-4071-928c-26f0c7ccc4fb)


## Setup Webhooks on Server
Add a webhook to your repository to automatically build and deploy the docker container on push to ```main``` branch.

```
npm install
npm install forever -g
npm run start
```

This runs ```webhook/hook.js``` in background on ```http://localhost:4000/webhook``` and starts docker compose.

Next time you push to main, the webhook will be triggered and the docker container will be updated and restart automatically.

### Local Development
You can use https://smee.io/ to create a webhook proxy to your local machine. [Full tutorial](https://docs.github.com/en/webhooks/using-webhooks/handling-webhook-deliveries)

## Release

To create a new release, create a new tag and push it to the repository.

```bash
git tag -a v0.0.1 -m "Initial Release"
git push origin v0.0.1
```


## Recurring Errors
**If "The CSRF session token is missing." error occures**

Close pgadmin session in browser tab and retry.
