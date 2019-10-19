FROM alpine:3.10.2

ENV NODEJS_VERSION="12.12.0" \
    NPM_VERSION="6.12.0" \
    YARN_VERSION="1.19.1"

RUN set -e;\
  apk add --no-cache --virtual .docker git;\
  apk add --no-cache --virtual .docker-package-integrity gnupg;\
  apk add --no-cache --virtual .docker-nodejs libstdc++;\
  apk add --no-cache --virtual .docker-nodejs-builder make gcc g++ python linux-headers libgcc;\
  mkdir -p /tmp/nodejs;\
  (\
    cd /tmp/nodejs;\
    wget -q "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}.tar.xz";\
    wget -q "https://nodejs.org/dist/v${NODEJS_VERSION}/SHASUMS256.txt.asc";\
    git clone https://github.com/canterberry/nodejs-keys.git keys;\
    GNUPGHOME=keys/gpg gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc;\
    grep " node-v${NODEJS_VERSION}.tar.xz\$" SHASUMS256.txt | sha256sum -c - | grep -q ': OK$';\
    tar xJf "node-v${NODEJS_VERSION}.tar.xz" --strip-components=1 --no-same-owner;\
    ./configure --prefix=/usr;\
    make -j4;\
    make install;\
  );\
  rm -fR /tmp/nodejs;\
  apk del .docker-nodejs-builder;\
  /usr/bin/npm install --global "npm@${NPM_VERSION}";\
  mkdir -p /usr/share/yarn;\
  cd /usr/share/yarn;\
  wget -q "https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz";\
  wget -q "https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz.asc";\
  wget -q -O - "https://dl.yarnpkg.com/debian/pubkey.gpg" | gpg --import;\
  gpg --verify "yarn-v${YARN_VERSION}.tar.gz.asc";\
  tar xzf "yarn-v${YARN_VERSION}.tar.gz" --strip-components=1 --no-same-owner;\
  rm -f \
    "yarn-v${YARN_VERSION}.tar.gz" \
    "yarn-v${YARN_VERSION}.tar.gz.asc" \
  ;\
  chmod -fR go+rX,go-w .;\
  ln -vs "/usr/share/yarn/bin/yarn" "/usr/bin/yarn";\
  apk del .docker-package-integrity;\
  addgroup -g 1234 -S docker;\
  adduser -h /docker -g '' -s /bin/bash -G docker -S -D -u 1234 docker

WORKDIR /docker

USER docker
