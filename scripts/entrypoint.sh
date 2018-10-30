#! /usr/bin/env bash

set -e

#
# This script assume your database server is running. No checks will be done
#

export MAUTIC_PATH=/var/www/html
export MAUTIC_LOCAL_PATH="${MAUTIC_PATH}/app/local"
export MAUTIC_LOCAL_CACHE="${MAUTIC_LOCAL_PATH}/cache/prod"
export MAUTIC_LOCAL_CONFIG="${MAUTIC_LOCAL_PATH}/config"
export MAUTIC_LOCAL_THEMES="${MAUTIC_LOCAL_PATH}/themes"
export MAUTIC_LOCAL_IDP="${MAUTIC_LOCAL_PATH}/idp"
export MAUTIC_LOCAL_MEDIA_FILES="${MAUTIC_LOCAL_PATH}/media/files"
export MAUTIC_LOCAL_MEDIA_IMAGES="${MAUTIC_LOCAL_PATH}/media/images"
export MAUTIC_LOCAL_PLUGINS="${MAUTIC_LOCAL_PATH}/plugins"

# We are going to sudo around a lot
aswww="sudo -u www-data -g www-data"

# We create the log folder
mkdir -p /var/log/mautic

# We ensure all the right are good to go
chown -R www-data:www-data "${MAUTIC_LOCAL_PATH}" /var/log/mautic &

# First, we ensure that all the local folder exist.
# This is needed if one mount a new empty config folder
$aswww mkdir -p ${MAUTIC_LOCAL_CACHE}
$aswww mkdir -p ${MAUTIC_LOCAL_CONFIG}
$aswww mkdir -p ${MAUTIC_LOCAL_THEMES}
$aswww mkdir -p ${MAUTIC_LOCAL_IDP}
$aswww mkdir -p ${MAUTIC_LOCAL_MEDIA_FILES}
$aswww mkdir -p ${MAUTIC_LOCAL_MEDIA_IMAGES}
$aswww mkdir -p ${MAUTIC_LOCAL_PLUGINS}

# We link any pré-existing plugins to the local plugin folder
$aswww find "${MAUTIC_LOCAL_PLUGINS}" -maxdepth 1 -mindepth 1 -type d -print0 |
$aswww xargs --no-run-if-empty -0 ln -s -t "${MAUTIC_PATH}/plugins"

# Now, we create the initial configuration file if none already exist
if ! test -e "${MAUTIC_LOCAL_CONFIG}/local.php" ;
then
    logger "no local configuration found, generating the default one"
    $aswww -E php /usr/local/share/mautic/scripts/makeconfig.php
fi

# Now we run a serie of mautic preparation commandes
#logger "clearing Mautic cache"
#$aswww /var/www/html/app/console cache:clear
#logger "warming Mautic cache"
#$aswww /var/www/html/app/console cache:warm
#logger "running database migration for Mautic"
#$aswww /var/www/html/app/console doctrine:migration:migrate --no-interaction

logger "starting runit"
export > /etc/envvars && /usr/sbin/runsvdir-start

