FROM lsiobase/ubuntu:bionic as builder

# set version label
LABEL build_version="SuperNG6.qbittorrentEE:- ${QBITTORRENT_VER}"
LABEL maintainer="SuperNG6"
# builde qBittorrent Enhanced Edition
COPY qbittorrent-nox-static-glibc.sh /tmp/qbittorrent-nox-static-glibc.sh
RUN chmod +x /tmp/qbittorrent-nox-static-glibc.sh
RUN /tmp/qbittorrent-nox-static-glibc.sh
RUN /tmp/qbittorrent-nox-static-glibc.sh install

# docker qBittorrent-Enhanced-Edition
FROM lsiobase/ubuntu:bionic

# environment settings
ENV TZ=Asia/Shanghai
ENV WEBUIPORT=8080

# add local files and install qbitorrent
COPY root /
COPY --from=builder /qbittorrent-build/bin/qbittorrent-nox /usr/local/bin/qbittorrent-nox

RUN chmod a+x /usr/local/bin/qbittorrent-nox  

# ports and volumes
VOLUME /downloads /config
EXPOSE 8080  6881  6881/udp
