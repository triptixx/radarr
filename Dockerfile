ARG ALPINE_TAG=3.10
ARG DOTNET_TAG=3.0
ARG RADARR_VER=

FROM mcr.microsoft.com/dotnet/core/sdk:${DOTNET_TAG}-alpine AS builder

ARG RADARR_VER
ARG DOTNET_TAG

### install radarr
WORKDIR /radarr-src
RUN apk add --no-cache git jq binutils file; \
    COMMITID=$(wget -q -O- https://ci.appveyor.com/api/projects/Jackett/jackett/build/${JACKETT_VER} \
        | jq -r '.build.commitId'); \
    git clone https://github.com/Jackett/Jackett.git .; \
    git checkout $COMMITID; \
    echo '{"configProperties":{"System.Globalization.Invariant":true}}' > src/Jackett.Server/runtimeconfig.template.json; \
    dotnet publish -p:Version=${JACKETT_VER} -p:TrimUnusedDependencies=true -c Release -f netcoreapp${DOTNET_TAG} \
        -r linux-musl-x64 -o /output/jackett src/Jackett.Server; \
    find /output/jackett -exec sh -c 'file "{}" | grep -q ELF && strip --strip-debug "{}"' \;

COPY *.sh /output/usr/local/bin/
RUN chmod -R u=rwX,go=rX /output/jackett; \
    chmod +x /output/usr/local/bin/*.sh /output/jackett/jackett

#=============================================================

FROM loxoo/alpine:${ALPINE_TAG}

ARG RADARR_VER
ENV SUID=931 SGID=900

LABEL org.label-schema.name="radarr" \
      org.label-schema.description="A Docker image for the Movies management software Radarr" \
      org.label-schema.url="https://radarr.video" \
      org.label-schema.version=${RADARR_VER}

COPY --from=builder /output/ /

RUN apk add --no-cache sqlite-libs libmediainfo xmlstarlet

VOLUME ["/config", "/medias"]

EXPOSE 7878/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null 'http://localhost:7878/api/system/status' \
            --header "x-api-key: $(xmlstarlet sel -t -v '/Config/ApiKey' /config/config.xml)"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/radarr/radarr", "--no-browser", "--data=/config"]
