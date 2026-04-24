# kiosk-screensaver

Kiosk pages served at [kiosk.nj.menzer.org](https://kiosk.nj.menzer.org) for Home Assistant Fully Kiosk tablets.

## Pages

| URL | File | Description |
|-----|------|-------------|
| [/screensaver](https://kiosk.nj.menzer.org/screensaver) | `screensaver.html` | Clock, date, weather, Sonos album art background |

The index at `/` lists all pages and links to this repo.

## Screensaver features

- **Clock** — 24-hour, large and bold
- **Date** — day of week, month, day
- **Weather** — current temp (°C), conditions, day's high/low, precipitation chance + type for the rest of the day; from [Open-Meteo](https://open-meteo.com/) (free, no API key); refreshes every 10 minutes
- **Album art background** — when a Sonos speaker is playing, its album art fills the background; checks kitchen → living room → backyard in priority order; updates every 5 seconds
- Pure static HTML + JavaScript, no build step

## Fully Kiosk URL

```
https://kiosk.nj.menzer.org/screensaver
```

## Configuration

Location and timezone are hardcoded near the top of `screensaver.html`:

```js
const LAT = 40.7598;
const LON = -74.4160;
const TIMEZONE = 'America/New_York';
```

Sonos room priority order (first playing room wins):

```js
const SONOS_ROOMS = [
    { entity: 'media_player.kitchen_sonos' },
    { entity: 'media_player.living_room_sonos' },
    { entity: 'media_player.backyard_sonos' },
];
```

## Infrastructure

| Property | Value |
|----------|-------|
| **Host** | `kiosk-app` — Proxmox LXC 118 on proxmox-app |
| **IP** | `192.168.10.33` (DHCP reservation on main interface, MAC `BC:24:11:69:52:ED`) |
| **OS** | Debian 12 |
| **Resources** | 1 core, 512 MB RAM, 4 GB disk |
| **Web server** | nginx, serving from `/var/www/html/`; extensionless URLs via `try_files $uri $uri.html` |
| **DNS** | OPNsense Unbound override: `kiosk.nj.menzer.org` → `192.168.50.50` (Nginx Proxy Manager) |
| **Proxy** | NPM host #24: `kiosk.nj.menzer.org` → `192.168.10.33:80`, SSL forced |
| **SSH** | `ssh root@kiosk-app.nj.menzer.org` |

## Home Assistant proxy (`/ha/`)

The screensaver fetches Sonos state from Home Assistant via a `/ha/` reverse proxy on kiosk-app's nginx. This exists because:

1. The browser can't call HA directly — CORS blocks cross-origin requests
2. NPM sits between the browser and kiosk-app and strips `Authorization` headers, so we can't send the HA token from JS

**Solution:** kiosk-app's nginx injects the HA long-lived access token server-side. The browser sends no token — nginx adds it before forwarding to HA.

**nginx config** (`/etc/nginx/sites-enabled/default`):

```nginx
location /ha/ {
    proxy_pass http://192.168.10.2:8123/;
    proxy_set_header Authorization "Bearer <HA_TOKEN>";
    # Strip X-Forwarded-* headers NPM injects — HA rejects requests with these
    # from untrusted proxies and returns 400
    proxy_set_header X-Forwarded-For "";
    proxy_set_header X-Real-IP "";
    proxy_set_header X-Forwarded-Proto "";
    proxy_set_header X-Forwarded-Host "";
}
```

The HA token lives only in this nginx config on kiosk-app — never in client-side code.

**Why X-Forwarded headers must be stripped:** NPM adds `X-Forwarded-For`, `X-Real-IP`, etc. when proxying to kiosk-app. Kiosk-app's nginx then forwards these to HA. HA treats these as untrusted proxy headers and returns `400 Bad Request`. Clearing them before forwarding to HA fixes this.

## Deployment

```bash
./deploy.sh
```

SCPs `screensaver.html` and `index.html` to `/var/www/html/` on kiosk-app. Note: nginx config on kiosk-app is **not** managed by this repo — edit it directly via SSH.

## Adding a new page

1. Add a `.html` file to the repo
2. Add a card for it in `index.html`
3. Run `./deploy.sh`
