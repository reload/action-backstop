# This is based on https://github.com/garris/BackstopJS/blob/master/docker/Dockerfile
FROM node:10.15.3

# Hadolint likes packages being pinned, but that's a tad unhandy for our usecase.
# hadolint ignore=DL3008
RUN apt-get -qqy update \
        && apt-get -qqy --no-install-recommends install \
        git \
        software-properties-common \
        libfontconfig \
        libfreetype6 \
        xfonts-cyrillic \
        xfonts-scalable \
        fonts-liberation \
        fonts-ipafont-gothic \
        fonts-wqy-zenhei \
        gconf-service \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgcc1 \
        libgconf-2-4 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxss1 \
        libxtst6 \
        libappindicator1 \
        libnss3 \
        libasound2 \
        libatk1.0-0 \
        libc6 \
        ca-certificates \
        fonts-liberation \
        lsb-release \
        xdg-utils \
        wget \
        jq \
        rsync \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get -qyy clean

# Use backstopjs@${BACKSTOPJS_VERSION} to get a specific version.
# hadolint ignore=DL3016
RUN npm install -g --unsafe-perm=true --allow-root backstopjs

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod a+x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
