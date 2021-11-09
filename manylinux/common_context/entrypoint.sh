#!/bin/bash

USERNAME_=${LOCAL_USER:-dxt}
UID_=${LOCAL_UID:-1000}
GID_=${LOCAL_GID:-$UID_}

export LANG=en_US.UTF-8
echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts

# we are running as root, if UID_ == 0, there is little we can do but continue ...
if [[ $UID_ == 0 ]] ; then
  if [ "X$@" == "X" ]; then
    exec /bin/bash
  else
    exec "$@"
  fi
  exit
fi

echo "Starting with UID : $USER_ID"

# ... else, check if there exist a group and create it otherwise
[[ $(getent group $GID_) ]] || groupadd -g $GID_ $USERNAME_ &> /dev/null

# check if a user with id $UID_ already exists
if [[ $(id -u $UID_ &> /dev/null) ]]; then
  # unconditionally set the primary group of the user
  usermod -g $GID_ $UID_
  # rename the user if required
  [[ "$USERNAME_" == "$(id -un $UID_)" ]] || usermod -l $USERNAME_ $(id -un $UID_)
else
  # otherwise create the user
  [[ -e /home/$USERNAME_ ]] && export m_= || export m_=m
  useradd -${m_}d /home/$USERNAME_ -g $GID_ -s /bin/bash -u $UID_ $USERNAME_
fi

# give the user some sudo capabilities
if [[ $UID_ != 0 ]] ; then
  echo "$USERNAME_ ALL=(ALL) NOPASSWD:/usr/bin/yum" >> /etc/sudoers
fi

if [ "X$@" == "X" ]; then
  exec gosu $USERNAME_ /bin/bash
else
  exec gosu $USERNAME_ "$@"
fi
