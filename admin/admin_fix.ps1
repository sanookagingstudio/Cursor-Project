Param()

docker system prune -af

docker compose -f ../docker-compose.sas.yml build --no-cache

docker compose -f ../docker-compose.sas.yml up -d --force-recreate
