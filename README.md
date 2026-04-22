# kiosk-screensaver

Fullscreen screensaver page for Home Assistant Fully Kiosk tablets. Shows the current time, date, and local weather.

## Features

- **Clock** — large, readable from across the room
- **Date** — day of week, month, day
- **Weather** — current temperature, conditions, day's high/low, and max precipitation probability for the rest of the day
- Weather data from [Open-Meteo](https://open-meteo.com/) — free, no API key required
- Weather refreshes every 10 minutes; clock updates every second
- Pure static HTML + JavaScript, no build step

## Usage

Point Fully Kiosk's screensaver URL to:

```
https://kiosk.nj.menzer.org
```

## Configuration

Location is hardcoded at the top of `index.html`:

```js
const LAT = 40.7598;
const LON = -74.4160;
const TIMEZONE = 'America/New_York';
```

Update these for a different location.

## Infrastructure

| Property | Value |
|----------|-------|
| **Host** | `kiosk-app` — Proxmox LXC 118 on proxmox-app |
| **IP** | `192.168.10.33` (DHCP reservation, MAC `BC:24:11:69:52:ED`) |
| **OS** | Debian 12 |
| **Resources** | 1 core, 512 MB RAM, 4 GB disk |
| **Web server** | nginx, serving from `/var/www/html/` |
| **URL** | `https://kiosk.nj.menzer.org` |
| **DNS** | OPNsense Unbound override: `kiosk.nj.menzer.org` → `192.168.50.50` (nginx proxy) |
| **Proxy** | Nginx Proxy Manager host #24: `kiosk.nj.menzer.org` → `192.168.10.33:80` |

## Deployment

Copy `index.html` to the LXC via Proxmox:

```bash
# From proxmox-app
pct exec 118 -- bash -c 'cat > /var/www/html/index.html' < index.html
```

Or SCP directly once SSH keys are set up on the container:

```bash
scp index.html root@192.168.10.33:/var/www/html/index.html
```
