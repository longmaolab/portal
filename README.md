# boobank games portal

Landing page at <https://game.boobank.com> listing all games hosted on this domain.

## What this is

Plain HTML/CSS, no JS frameworks. Lists each game as a card with thumbnail,
description, and link.

## Where it runs

Served by Caddy on the Vultr server, route `/` → `/opt/games/portal/`.

## Add a new game

1. Drop a thumbnail (16:9, ~600x340px PNG/JPG) into `thumbnails/`.
2. Add a new `<a class="card playable">` block in `index.html`.
3. `git push` — server's auto-deploy hook (or manual `git pull`) updates it.

That's it. No build step.

## Local preview

```bash
python3 -m http.server 8000
# open http://localhost:8000
```
