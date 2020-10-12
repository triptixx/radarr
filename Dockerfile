ARG ALPINE_TAG=3.12
ARG RADARR_VER=3.0.0.3918

FROM loxoo/alpine:${ALPINE_TAG} AS builder

ARG RADARR_VER

### install sonarr
WORKDIR /output/radarr
RUN apk add --no-cache curl; \
    curl -fsSL "https://radarr.servarr.com/v1/update/nightly/updatefile?version=${RADARR_VER}&os=linuxmusl&runtime=netcore&arch=x64" \
        | tar xz --strip-components=1; \
    find . -name '*.mdb' -delete; \
    find ./UI -name '*.map' -delete; \
    rm -r Radarr.Update

COPY *.sh /output/usr/local/bin/
RUN chmod +x /output/usr/local/bin/*.sh

#=============================================================

FROM loxoo/alpine:${ALPINE_TAG}

ARG RADARR_VER
ENV SUID=932 SGID=900

LABEL org.label-schema.name="radarr" \
      org.label-schema.description="A Docker image for the Movies management software Radarr" \
      org.label-schema.url="https://radarr.video" \
      org.label-schema.version=${RADARR_VER}

COPY --from=builder /output/ /

RUN apk add --no-cache libstdc++ libgcc libintl icu-libs sqlite-libs libmediainfo xmlstarlet

VOLUME ["/config"]

EXPOSE 7878/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:7878/api/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/radarr/Radarr", "--no-browser", "--data=/config"]