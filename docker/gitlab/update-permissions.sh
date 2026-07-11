#!/bin/bash
docker compose up -d
sleep 5
docker exec -it $(docker ps -qf "name=gitlab") update-permissions