#!/bin/sh
set -e

# Number of Requests to make to each server
REQUESTS=5
# REQUESTS>16 will timeout when SQLAlchemy is blocking

echo "Start Database"
docker-compose run --name afse_web web sleep 5
# Doesn't stop the db
docker-compose rm -f web
echo
echo "Gunicorn blocking with SQLAlchemy blocking"
echo "------------------------------------------"
docker-compose run -d --name afse_web web gunicorn server:app # Similar to flask run speeds
sleep 2 # Wait for server
# Setup database - MUST HAPPEN
docker exec -it afse_web python server.py -c
docker exec -it afse_web python client.py $REQUESTS
docker stop afse_web
docker-compose rm -f web
echo
echo "Gunicorn workers=4 blocking with SQLAlchemy blocking"
echo "----------------------------------------------"
docker-compose run -d --name afse_web web gunicorn server:app --workers 4
sleep 2 # Wait for server
docker exec -it afse_web python client.py $REQUESTS
docker stop afse_web
docker-compose rm -f web
echo
echo "Gunicorn non-blocking with SQLAlchemy blocking"
echo "----------------------------------------------"
docker-compose run -d --name afse_web web gunicorn server:app -k gevent
sleep 2 # Wait for server
docker exec -it afse_web python client.py $REQUESTS
docker stop afse_web
docker-compose rm -f web
echo
echo "Gunicorn workers=4 non-blocking with SQLAlchemy blocking"
echo "--------------------------------------------------------"
docker-compose run -d --name afse_web web gunicorn server:app -k gevent --workers 4
sleep 2 # Wait for server
docker exec -it afse_web python client.py $REQUESTS
docker stop afse_web
docker-compose rm -f web
echo
echo "Gunicorn non-blocking with SQLAlchemy non-blocking"
echo "--------------------------------------------------"
docker-compose run -d --name afse_web -e PSYCOGREEN=true web gunicorn server:app -k gevent 
sleep 2 # Wait for server
docker exec -it afse_web python client.py $REQUESTS
docker stop afse_web
docker-compose rm -f web
echo
echo "Gunicorn workers=4 non-blocking with SQLAlchemy non-blocking"
echo "--------------------------------------------------"
docker-compose run -d --name afse_web -e PSYCOGREEN=true web gunicorn server:app -k gevent --workers 4
sleep 2 # Wait for server
docker exec -it afse_web python client.py $REQUESTS
docker stop afse_web
docker-compose rm -f web
echo
echo "Clean Up"
echo "--------"
docker-compose stop db
docker-compose rm -f db
