FROM alpine:3.8

ENV USER=jenkins \
    UID=10000

ENV NIX_PROFILE=/nix/var/nix/profiles/per-user/$USER/profile \
    NIX_CHANNELS=/nix/var/nix/profiles/per-user/$USER/channels

# Prerequisites
RUN apk add --no-cache --update openssl sudo && \
    # Add non-root user
    addgroup -g $UID $USER && \
    adduser -u $UID $USER -G $USER -D && \
    # Give them elevated privileges during Nix install
    cp -p /etc/sudoers /etc/sudoers.orig && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Non-root single-user Nix installation
USER $USER
WORKDIR /home/$USER
COPY ./nix-install.sh ./nix-install.sh
RUN ./nix-install.sh && \
    sudo ln -s $NIX_PROFILE/etc/profile.d/nix.sh /etc/profile.d/ && \
    sudo mv /etc/sudoers.orig /etc/sudoers && \
    rm nix-install.sh

ENV ENV=/etc/profile \
    PATH=$NIX_PROFILE/bin:$NIX_PROFILE/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=$NIX_PROFILE/etc/ssl/certs/ca-bundle.crt \
    NIX_SSL_CERT_FILE=$NIX_PROFILE/etc/ssl/certs/ca-bundle.crt \
    NIX_PATH=$NIX_CHANNELS \
    LOCALE_ARCHIVE=$NIX_PROFILE/lib/locale/locale-archive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PAGER=cat

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && \
    nix-channel --update

# Construct a basic environment
RUN nix-env --file '<nixpkgs>' --install --attr \
      bashInteractive \
      bats \
      binutils \
      cacert \
      coreutils \
      diffutils \
      gitMinimal \
      glibcLocales \
      gnugrep \
      gnutar \
      gzip \
      iana-etc \
      openssh \
      rsync \
      xz

# Cleanup
RUN nix-collect-garbage --delete-old && \
    nix-store --verify --check-contents && \
    rm -f /home/$USER/.ash_history

CMD "bash"
