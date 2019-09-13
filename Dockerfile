FROM debian:stretch

ENV NODEJS_VERSION="12.10.0" \
    NPM_VERSION="6.11.3" \
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
  mkdir -p /usr/share/nodejs;\
  cd /usr/share/nodejs;\
  wget -q "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz";\
  wget -q "https://nodejs.org/dist/v${NODEJS_VERSION}/SHASUMS256.txt.asc";\
  git clone https://github.com/canterberry/nodejs-keys.git keys;\
  GNUPGHOME=keys/gpg gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc;\
  rm -fR keys;\
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
