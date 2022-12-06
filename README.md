# Mantra

## Development

Couchdb can be started and ran through docker by running:

```bash
docker-compose up
```

See `compose.yaml` for port, username, and password for couch instance. Given port is at "5984" then the admin interface for couch can be accesed at `localhost:5984/_utils`.

## CouchDB Views

Views are maintained in this repo in the `/priv/couch` folder. To sync views with couch database run `mix couch.view.sync`.
