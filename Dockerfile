FROM ubuntu:17.10
LABEL maintainer "m-maeda@feedforce.jp"

ENV RUBY_VERSION=2.5.0 \
    BUNDLER_VERSION=1.16.1 \
    NODE_VERSION=9.6.1 \
    NPM_VERSION=5.6.0

RUN apt-get update && apt-get install -y git tar curl openssl libpq-dev tzdata

# set timezone JST
RUN ln -fs /usr/share/zoneinfo/Japan /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# for lang
RUN apt-get install -y language-pack-ja-base language-pack-ja ibus-mozc locales && rm -rf /var/lib/apt/lists/* && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.utf8

ENV LANG ja_JP.utf8

RUN apt-get update && apt-get install -y pkg-config libtool-bin bzip2 g++ make \
    autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
    libncurses5-dev libffi-dev libgdbm3 libgdbm-dev qt5-default libqt5webkit5-dev imagemagick libmysqld-dev

# install ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
    cd /tmp/ruby-build && \
    ./install.sh && \
    cd / && \
    rm -rf /tmp/ruby-build

# Install ruby & gems
RUN CONFIGURE_OPTS="--disable-install-doc" ruby-build -v ${RUBY_VERSION} /usr/local && \
    gem install bundler:${BUNDLER_VERSION} rubygems-bundler --no-rdoc --no-ri && \
    gem regenerate_binstubs && \
    rm -rf /tmp/ruby-build*

# node
RUN apt-get install -y nodejs npm && \
    npm cache clean && npm install n -g && n ${NODE_VERSION} && \
    ln -sf /usr/local/bin/node /usr/bin/node && apt-get purge -y nodejs npm

RUN apt-get install -y postgresql-client && apt-get -y autoremove

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH "$GEM_HOME"
ENV BUNDLE_BIN "$GEM_HOME/bin"
ENV BUNDLE_SILENCE_ROOT_WARNING 1
ENV BUNDLE_APP_CONFIG "$GEM_HOME"
ENV BUNDLE_JOBS 4
ENV BUNDLE_RETRY 3
ENV PATH "$BUNDLE_BIN:$PATH"

COPY scripts/wait-for-postgres.sh /root/
WORKDIR /app

