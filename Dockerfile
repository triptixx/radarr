ARG ALPINE_TAG=3.15
ARG RADARR_VER=4.0.5.5981

FROM loxoo/alpine:${ALPINE_TAG} AS builder

ARG RADARR_VER

### install sonarr
WORKDIR /output/radarr
RUN wget -O- https://github.com/Radarr/Radarr/releases/download/v${RADARR_VER}/Radarr.master.${RADARR_VER}.linux-musl-core-x64.tar.gz \
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
