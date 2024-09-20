# Backend Services

These will be the various services that deal with things inside AWS. There might be one or two that are user-facing (eg, an API), but most of them will just be in an internal private subnet.

## Local dev

You can run the entire stack (literally just one service, at the moment) via docker compose. In this directory, run

```sh
docker compose up --build
```

...and you should get the service listening on port 8001, which the postgres database (in a container) serving the backend data needs. To put some data in here, you can send POST requests via curl:

```sh
curl -X POST localhost:8001 \
  -d '{"reviewer": "Pat", "rating": 4, "comment": "its all good, playa!"}' \
  -H "Content-Type: application/json" 
```

...and we'll probably have some convenience script using faker to put in a bunch of auto-generated data at some point.

## Reviews Service

This is a service written in typescript that will store and retrieve reviews. It currently talks to a postgres database.

