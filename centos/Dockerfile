FROM centos:7

ENV USER=fnord \
    UID=1000

ENV NIX_PROFILE=/nix/var/nix/profiles/per-user/$USER/profile \
    NIX_CHANNELS=/nix/var/nix/profiles/per-user/$USER/channels

# Prerequisites
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum -y install sudo openssl bzip2 wget && \
    yum -y clean all && \
    # Add non-root user
    groupadd --gid $UID $USER && \
    adduser --uid $UID $USER --gid $USER && \
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

# RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && \
#     nix-channel --update

# Install desired packages, e.g.
# RUN nix-env --file '<nixpkgs>' --install --attr \
#       man
#       git
#       jq

# Cleanup
RUN nix-collect-garbage --delete-old && \
    nix-store --verify --check-contents
