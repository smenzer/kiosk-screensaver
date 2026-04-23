# kiosk-screensaver

Kiosk pages served at [kiosk.nj.menzer.org](https://kiosk.nj.menzer.org) for Home Assistant Fully Kiosk tablets.

## Pages

| URL | File | Description |
|-----|------|-------------|
| [/screensaver](https://kiosk.nj.menzer.org/screensaver) | `screensaver.html` | Clock, date, and local weather |

The index at `/` lists all pages and links to this repo.

## Screensaver features

- **Clock** — 24-hour, large and bold
- **Date** — day of week, month, day
- **Weather** — current temp (°C), conditions, day's high/low, precipitation chance + type for the rest of the day
- Weather from [Open-Meteo](https://open-meteo.com/) — free, no API key required; refreshes every 10 minutes
- Pure static HTML + JavaScript, no build step

## Fully Kiosk URL

```
https://kiosk.nj.menzer.org/screensaver
```

## Configuration

Location is hardcoded near the top of `screensaver.html`:

```js
const LAT = 40.7598;
const LON = -74.4160;
const TIMEZONE = 'America/New_York';
```

## Infrastructure

| Property | Value |
|----------|-------|
| **Host** | `kiosk-app` — Proxmox LXC 118 on proxmox-app |
| **IP** | `192.168.10.33` (DHCP reservation on main interface, MAC `BC:24:11:69:52:ED`) |
| **OS** | Debian 12 |
| **Resources** | 1 core, 512 MB RAM, 4 GB disk |
| **Web server** | nginx, serving from `/var/www/html/`; extensionless URLs via `try_files $uri $uri.html` |
| **DNS** | OPNsense Unbound override: `kiosk.nj.menzer.org` → `192.168.50.50` (nginx proxy) |
| **Proxy** | Nginx Proxy Manager host #24: `kiosk.nj.menzer.org` → `192.168.10.33:80`, SSL forced |
| **SSH** | `ssh root@kiosk-app.nj.menzer.org` |

## Deployment

```bash
./deploy.sh
```

SCPs `screensaver.html` and `index.html` to `/var/www/html/` on kiosk-app.

## Adding a new page

1. Add a `.html` file to the repo
2. Add a card for it in `index.html`
3. Run `./deploy.sh`
