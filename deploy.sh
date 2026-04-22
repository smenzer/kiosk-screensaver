#!/bin/bash
set -e
scp index.html root@kiosk-app.nj.menzer.org:/var/www/html/index.html
echo "Deployed."
