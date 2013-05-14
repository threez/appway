#!/bin/bash

HOST=http://localhost:8000
APPWAY="X-App: appway"

echo "== Delete the example app if it is already there"
curl -X DELETE -H "$APPWAY" $HOST/applications/example
echo
sleep 1

echo "== Create example app"
curl -i -X POST -H "$APPWAY" -H 'Content-Type: application/json' -d @example.json $HOST/applications
echo
sleep 1

echo "== Show all applications"
curl -H "$APPWAY" $HOST/applications
echo
sleep 1

echo "== Show the example application"
curl -H "$APPWAY" $HOST/applications/example
echo
sleep 1

echo "== Redeploy the application"
curl -X POST -H "$APPWAY" $HOST/applications/example/redeploy
echo
sleep 1

echo "== Remove the application"
curl -X DELETE -H "$APPWAY" $HOST/applications/example
echo
sleep 1

echo "== DONE"