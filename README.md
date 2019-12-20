[hub]: https://hub.docker.com/r/loxoo/radarr
[mbdg]: https://microbadger.com/images/loxoo/radarr
[git]: https://github.com/triptixx/radarr
[actions]: https://github.com/triptixx/radarr/actions

# [loxoo/radarr][hub]
[![Layers](https://images.microbadger.com/badges/image/loxoo/radarr.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/loxoo/radarr.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/loxoo/radarr.svg)][git]
[![Docker Stars](https://img.shields.io/docker/stars/loxoo/radarr.svg)][hub]
[![Docker Pulls](https://img.shields.io/docker/pulls/loxoo/radarr.svg)][hub]
[![Build Status](https://github.com/triptixx/radarr/workflows/docker%20build/badge.svg)][actions]

## Usage

```shell
docker run -d \
    --name=srvradarr \
    --restart=unless-stopped \
    --hostname=srvradarr \
    -p 7878:7878 \
    -v $PWD/config:/config \
    -v $PWD/medias:/medias \
    -v $PWD/watchclient:/watch
    -v $PWD/downloadclient:/download \
    loxoo/radarr
```

## Environment

- `$API_KEY`      - API Key authentication. _optional_
- `$ANALYTICS`    - Enable send Anonymous Usage Data. _default: `false`_
- `$BRANCH`       - Upstream tracking branch for updates. _default: `master`_
- `$ENABLE_SSL`   - Enable SSL. _default: `false`_
- `$LOG_LEVEL`    - Logging severity levels. _default: `info`_
- `$URL_BASE`     - URL Base configuration. _optional_
- `$SUID`         - User ID to run as. _default: `931`_
- `$SGID`         - Group ID to run as. _default: `900`_
- `$TZ`           - Timezone. _optional_

## Volume

- `/config`       - Server configuration file location.
- `/medias`       - Location of Media library.

## Network

- `7878/tcp`      - WebUI.
