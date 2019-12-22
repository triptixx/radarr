#!/bin/sh
set -eo pipefail

# ANSI colour escape sequences
RED='\033[0;31m'
RESET='\033[0m'
error() { >&2 echo -e "${RED}Error: $@${RESET}"; exit 1; }

CONF_RADARR='/config/config.xml'
CONF_RADARR_BAK="$(mktemp -u "$CONF_RADARR.bak.XXXXXX")"

if [ -f "$CONF_RADARR" ]; then
    # Preserve old configuration, in case of ENOSPC or other errors
    cp "$CONF_RADARR" "$CONF_RADARR_BAK" || error 'Could not backup config file'
fi

getOpt() {
    xmlstarlet sel -t -c /Config/"$1" "$CONF_RADARR"
}

setOpt() {
    # If element exists
    if xmlstarlet sel -Q -t -c "/Config/$1" "$CONF_RADARR"; then
        # Update the existing element
        xmlstarlet ed -O -L -u "/Config/$1" -v "$2" "$CONF_RADARR"
    else
        # Insert a new sub-element
        xmlstarlet ed -O -L -s /Config -t elem -n "$1" -v "$2" "$CONF_RADARR"
    fi
}

bool() {
    local var="$(echo "$1" | tr 'A-Z' 'a-z')"
    case "$var" in
        y|ye|yes|t|tr|tru|true|1)
            echo True;;
        n|no|f|fa|fal|fals|false|0)
            echo False;;
    esac
}
upper() { echo $1 | awk '{print toupper($0)}'; }
lower() { echo $1 | awk '{print tolower($0)}'; }
camel() { echo $1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'; }

# Create config.xml file and fill in some sane defaults (or fill existing empty file)
if [ ! -f "$CONF_RADARR" ] || [ ! -s "$CONF_RADARR" ]; then
    (echo '<Config>'; echo '</Config>') > "$CONF_RADARR"
    setOpt AnalyticsEnabled False
    setOpt Branch 'master'
    setOpt BindAddress '*'
    setOpt EnableSsl False
    setOpt LaunchBrowser False
    setOpt LogLevel 'info'
    setOpt UpdateAutomatically False
fi

# If they exist, add options that are specified in the environment
[ -n "$API_KEY" ]   && setOpt ApiKey $(lower "$API_KEY")
[ -n "$ANALYTICS" ] && setOpt AnalyticsEnabled $(bool "${ANALYTICS:-false}")
[ -n "$BRANCH" ] && setOpt Branch "${BRANCH:-master}"
[ -n "$ENABLE_SSL" ] && setOpt EnableSsl $(bool "${ENABLE_SSL:-false}")
[ -n "$LOG_LEVEL" ] && setOpt LogLevel $(camel "${LOG_LEVEL:-info}")
[ -n "$URL_BASE" ] && setOpt UrlBase "$URL_BASE"

# Format the document pretty :)
xmlstarlet fo "$CONF_RADARR" >/dev/null

# Finally, remove backup file after successfully creating new one
# This is done to prevent trampling the config when the disk is full
rm -f "$CONF_RADARR_BAK"
