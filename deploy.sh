#!/bin/bash
set -e
scp screensaver.html root@kiosk-app.nj.menzer.org:/var/www/html/screensaver.html
echo "Deployed."
