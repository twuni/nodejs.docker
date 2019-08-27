FROM debian:stretch

ENV NODEJS_VERSION="12.9.1" \
    NPM_VERSION="6.11.2" \
    YARN_VERSION="1.17.3"

RUN set -e;\
  apt-get update;\
  apt-get install \
    gnupg \
    wget \
    xz-utils \
    build-essential \
    ca-certificates \
    git \
    gzip \
    python \
    ssh \
  -y;

RUN set -e;\
  mkdir --mode=0700 ${HOME}/.gnupg;\
  echo "disable-ipv6" | tee -a ${HOME}/.gnupg/dirmngr.conf;\
  for KEY_ID in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
  ; do\
    gpg --keyserver hkps://192.146.137.98 --batch --receive-keys "${KEY_ID}";\
  done;

RUN set -e;\
  mkdir -p /usr/share/nodejs;\
  cd /usr/share/nodejs;\
  wget -q "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz";\
  wget -q "https://nodejs.org/dist/v${NODEJS_VERSION}/SHASUMS256.txt.asc";\
  gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc;\
  grep " node-v${NODEJS_VERSION}-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - | grep -q ': OK$';\
  tar xJf "node-v${NODEJS_VERSION}-linux-x64.tar.xz" --strip-components=1 --no-same-owner;\
  rm -f \
    "SHASUMS256.txt.asc" \
    "SHASUMS256.txt" \
    "node-v${NODEJS_VERSION}-linux-x64.tar.xz"\
  ;\
  chmod -fR go+rX,go-w .;\
  ln -vs "/usr/share/nodejs/bin/node" "/bin/node";\
  ln -vs "/usr/share/nodejs/bin/npm" "/bin/npm";\
  /bin/npm install --global "npm@${NPM_VERSION}";\
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
  ln -vs "/usr/share/yarn/bin/yarn" "/bin/yarn";\
  apt-get remove gnupg wget xz-utils -y;\
  apt-get autoremove -y;\
  apt-get install build-essential -y;\
  rm -vfR /var/lib/apt/lists/*;\
  addgroup --system --gid 1234 docker;\
  adduser --home /docker --gecos '' --shell /bin/bash --gid 1234 --system --disabled-login --uid 1234 docker;

USER docker
WORKDIR /docker
