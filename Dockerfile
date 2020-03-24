FROM lsiobase/ubuntu:bionic as builder

# set version label
ARG  LIBTORRENT_VER=1.1.14
ARG  QBITTORRENT_VER=4.1.9.15
LABEL build_version="SuperNG6.qbittorrentEE:- ${QBITTORRENT_VER}"
LABEL maintainer="SuperNG6"

# compiling
RUN apt -y update \
&&  apt-get -y install build-essential pkg-config automake libtool git zlib1g-dev \
&&  apt-get -y install libboost-dev libboost-system-dev libboost-chrono-dev libboost-random-dev libssl-dev libgeoip-dev \
&&  apt-get -y install qtbase5-dev qttools5-dev-tools libqt5svg5-dev \
&&  apt-get -y install geoip-database wget unzip \
&&  mkdir /qbittorrent \
&&  mkdir /qbittorrent-static \
&&  mkdir -p /compiling/libtorrent \
&&  mkdir -p /compiling/qbittorrent \
&&  git clone https://github.com/arvidn/libtorrent.git \
&&  cd libtorrent \
&&  git checkout RC_1_1 \
&&  ./autotool.sh \
&&  ./configure --disable-debug --enable-encryption \
&&  make -j$(nproc) install \
# qBittorrent-Enhanced-Edition
&&  wget --no-check-certificate -P /qbittorrent https://github.com/c0re100/qBittorrent-Enhanced-Edition/archive/release-${QBITTORRENT_VER}.zip \
&&  unzip /qbittorrent/release-${QBITTORRENT_VER}.zip -d /compiling \
&&  cd /compiling/qBittorrent-Enhanced-Edition-release-${QBITTORRENT_VER} \
# make install
&&  ./configure --disable-gui CXXFLAGS="-std=c++14" \
&&  make -j$(nproc) install \
&&  ldd /usr/local/bin/qbittorrent-nox | cut -d ">" -f 2 | grep lib | cut -d "(" -f 1 | xargs tar -chvf /tmp/qbittorrent.tar \
&&  tar -xvf /tmp/qbittorrent.tar -C /qbittorrent-static \
&&  cp --parents /usr/local/lib/libtorrent-rasterbar.so.9 /qbittorrent-static \
&&  cp --parents /usr/local/bin/qbittorrent-nox /qbittorrent-static
 

# Docker qBittorrent-Enhanced-Edition

FROM lsiobase/ubuntu:bionic

# environment settings
ENV TZ=Asia/Shanghai
ENV WEBUIPORT=8080 PUID=1026 PGID=100

# add local files and install qbitorrent
COPY root /
COPY --from=builder --chown=abc:abc /qbittorrent-static /

# install ca-certificates tzdata python3
RUN apt -y update \
&&  apt-get -y install ca-certificates python3 \
&&  chmod a+x /usr/local/bin/qbittorrent-nox \
&&  echo "**** cleanup ****" \
&&  apt-get clean \
&&  rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# ports and volumes
VOLUME /downloads /config
EXPOSE 8080  6881  6881/udp
