# Rusty

Bare-bones CFML app running on [RustCFML](https://github.com/RustCFML/RustCFML) in Docker.

## Run

Copy the local env template if you do not already have a `.env`:

```bash
cp .env.example .env
docker compose up -d --build
```

Visit:

```text
http://localhost:8500/
```

The root URL redirects to the compatibility test dashboard. The dashboard groups checks by migration status and links each row to an explanation page with an inline **Run test** action, plus nine Moopa Starter watch tests (issues 13–21) for patterns that should keep passing even when they are not current blockers.

The runnable CFML dashboard is the source of truth. The old static `MOOPA_RUSTCFML_COMPATIBILITY.html` map was removed because it drifted from the tests.

## Database

`docker compose` starts PostgreSQL 17 with a seeded `moo_role` table. SQL compatibility tests under `app/compatibility/` connect through `RUSTCFML_DSN_URL` in `.env`.

The seed schema lives in `db/init.sql`. To reset the database:

```bash
docker compose down -v
docker compose up -d --build
```

RustCFML v0.15.0 deserializes the direct UUID/timestamptz smoke query successfully. The compatibility harness still keeps JSON-wrapper and explicit-cast reads as regression-safe fallback patterns for more complex Moopa data shapes.

## URL rewrite probe

`app/urlrewrite.xml` contains a narrow clean-URL smoke rule:

```text
/rewrite-test/moopa-route?probe=ok
```

It forwards to `/_moopa.cfm?route=/rewrite-test/moopa-route&probe=ok`, matching Moopa's route-entry pattern closely enough for issue 03. If you edit `urlrewrite.xml`, restart the web container so RustCFML reloads the rules:

```bash
docker compose restart web
```

## Edit

Change files under `app/`. The compose setup bind-mounts `./app` into the container, so simple `.cfm` edits do not require an image rebuild. Rewrite-rule edits may require a web container restart.

## Stop

```bash
docker compose down
```
