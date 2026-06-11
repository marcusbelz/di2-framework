# Commands
## Create container
    docker compose -f ./docker.di2f.yml --env-file ./docker.di2f.dev.env up -d

## Bash
    docker exec -it di2f_dev_postgres /bin/bash

## Copy files to/from host
### Container > Host

    docker cp <container_name>:/var/lib/postgresql/data/postgresql.conf ./postgresql.conf

    docker cp di2f_dev_postgres:/var/lib/postgresql/data/postgresql.conf ./postgresql.conf

### Host > Container

    docker cp ./lokale-datei <container_name>:/path/in/container

    docker cp ./lokale-datei di2f_dev_postgres:/path/in/container

## Get mount point

    docker volume inspect <volume>

    docker volume inspect di2f_dev_pgdata

# Oder temporären Container mounten

    docker run --rm -it -v di2f_dev_pgdata:/data alpine sh
