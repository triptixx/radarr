ARG MONO_TAG=5.20.1.19
ARG RADARR_VER=3.0.0.2410

FROM loxoo/mono-runtime:${MONO_TAG} AS builder

ARG RADARR_VER

### install sonarr
WORKDIR /output/radarr
RUN apk add --no-cache curl; \
    curl -fsSL "https://radarr.lidarr.audio/v1/update/aphrodite/updatefile?version=${RADARR_VER}&os=linux&runtime=mono&arch=x64" \
        | tar xz --strip-components=1; \
    find . -name '*.mdb' -delete; \
    find ./UI -name '*.map' -delete; \
    rm -r Radarr.Update

COPY *.sh /output/usr/local/bin/
RUN chmod +x /output/usr/local/bin/*.sh

#=============================================================

FROM loxoo/mono-runtime:${MONO_TAG}

ARG RADARR_VER
ENV SUID=932 SGID=900

LABEL org.label-schema.name="radarr" \
      org.label-schema.description="A Docker image for the Movies management software Radarr" \
      org.label-schema.url="https://radarr.video" \
      org.label-schema.version=${RADARR_VER}

COPY --from=builder /output/ /

RUN apk add --no-cache sqlite-libs libmediainfo xmlstarlet

VOLUME ["/config"]

EXPOSE 7878/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:7878/api/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["mono", "/radarr/Radarr.exe", "--no-browser", "--data=/config"]
