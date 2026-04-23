#!/bin/bash
set -e
scp screensaver.html root@kiosk-app.nj.menzer.org:/var/www/html/screensaver.html
scp index.html root@kiosk-app.nj.menzer.org:/var/www/html/index.html
echo "Deployed."
