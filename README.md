[hub]: https://hub.docker.com/r/loxoo/radarr
[git]: https://github.com/triptixx/radarr/tree/master
[actions]: https://github.com/triptixx/radarr/actions/workflows/main.yml

# [loxoo/radarr][hub]
[![Git Commit](https://img.shields.io/github/last-commit/triptixx/radarr/master)][git]
[![Build Status](https://github.com/triptixx/radarr/actions/workflows/main.yml/badge.svg?branch=master)][actions]
[![Latest Version](https://img.shields.io/docker/v/loxoo/radarr/latest)][hub]
[![Size](https://img.shields.io/docker/image-size/loxoo/radarr/latest)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/loxoo/radarr.svg)][hub]
[![Docker Pulls](https://img.shields.io/docker/pulls/loxoo/radarr.svg)][hub]

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
- `$SUID`         - User ID to run as. _default: `932`_
- `$SGID`         - Group ID to run as. _default: `900`_
- `$TZ`           - Timezone. _optional_

## Volume

- `/config`       - Server configuration file location.
- `/medias`       - Location of Media library.

## Network

- `7878/tcp`      - WebUI.
