# Postgres + Postgrest
Basic example of initialising ```PostGres``` ```pgAdmin```, ```PostgREST``` and ```Swagger``` with docker compose on ubuntu. Creates generic Table ```product``` and adds values to it.

## 1. Download & Install Docker Desktop

https://docs.docker.com/desktop/install/ubuntu/


## 2. Run in Background

```bash
docker compose -f  docker-compose.yml --env-file ./.env.dev  up
```

### Potgrest
http://localhost:3000/

### Postgres
http://localhost:5432/

## Config

Change Credentials in ```config/_.env.dev``` and remove leading underscore.

Check docker-compose.yml config:

```bash
docker compose --env-file ./config/.env.dev config
```
More: https://docs.docker.com/compose/environment-variables/set-environment-variables/

## Stop
No Persistant DATA.

```bash
docker compose down --volumes
```

## ERROR
Close pgadmin and rerun. 
```
"The CSRF session token is missing."
```

## Reference
https://medium.com/@shlomi.fenster1/setup-local-environment-for-postgresql-5531b8268397

https://levelup.gitconnected.com/creating-and-filling-a-postgres-db-with-docker-compose-e1607f6f882f


https://shusson.info/post/building-nested-json-objects-with-postgres