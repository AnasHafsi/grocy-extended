#!/bin/sh
set -e

# On first boot against an empty volume, seed data/config.php from the
# shipped config-dist.php so the app doesn't hard-fail on missing config
# (see helpers/PrerequisiteChecker.php -> checkForConfigFile).
if [ ! -f "$GROCY_DATAPATH/config.php" ]; then
    echo "No config.php found in $GROCY_DATAPATH - copying config-dist.php as a starting point."
    echo "Edit $GROCY_DATAPATH/config.php afterwards to customize settings."
    cp /var/www/html/config-dist.php "$GROCY_DATAPATH/config.php"
fi

# A bind-mounted host directory is commonly root-owned; the app (running
# as www-data under Apache) needs to write the SQLite DB, viewcache,
# uploaded pictures, backups, etc. into it.
chown -R www-data:www-data "$GROCY_DATAPATH"

exec "$@"