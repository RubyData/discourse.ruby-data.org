#! /bin/bash

mitamae_version=1.5.1

USER_NAME=discourse
USER_UID=900
USER_GID=900
USER_HOME=/home/$$USER_NAME

groupadd -g $$USER_GID $$USER_NAME
useradd -u $$USER_UID -g $$USER_GID -G adm -m -s /bin/bash $$USER_NAME
mkdir -p $$USER_HOME/.ssh
chmod 700 $$USER_HOME/.ssh
echo -n "${authorized_keys}" > $$USER_HOME/.ssh/authorized_keys
chmod 600 $$USER_HOME/.ssh/authorized_keys
chown -R $${USER_NAME}:$${USER_NAME} $$USER_HOME

cat <<SUDO > /etc/sudoers.d/$$USER_NAME
Defaults:%infra !requiretty
Defaults:%infra env_keep += SSH_AUTH_SOCK
Defaults:%infra env_keep += "MITAMAE_ENVIRONMENT MITAMAE_ROLES MITAMAE_HOST MITAMAE_TEAM_NO"

%$$USER_NAME ALL=(ALL) NOPASSWD: ALL
SUDO

apt-get update -y
apt-get install -y curl ssh sudo

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
cat <<SSHD_CONFIG > /etc/ssh/sshd_config
${sshd_config_content}
SSHD_CONFIG

service ssh restart

mkdir -p /usr/local/sbin
curl -fsSL -o /usr/local/sbin/mitamae https://github.com/itamae-kitchen/mitamae/releases/download/v$${mitamae_version}/mitamae-x86_64-linux
chmod 755 /usr/local/sbin/mitamae
