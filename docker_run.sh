#!/bin/bash
#
# This file is part of the dune-community/Dockerfiles project:
#   https://github.com/dune-community/Dockerfiles
# Copyright 2017 dune-community/Dockerfiles developers and contributors. All rights reserved.
# License: Dual licensed as BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
#      or  GPL-2.0+ (http://opensource.org/licenses/gpl-license)
# Authors:
#   Felix Schindler (2017)
#   Rene Milk       (2017)

if (( "$#" < 3 )); then
  echo ""
  echo "usage: ${0}  CONTAINER  PROJECT  LIST_OF_COMMANDS"
  echo ""
  exit 1
fi

BASEDIR=${PWD}
CONTAINER=${1}
SYSTEM=${CONTAINER%%-*}
if echo $CONTAINER | xargs python -c "import sys; sys.exit('/' in sys.argv[1])" ; then
  # the container name does not have a prefix, assume it is from us
  export CONTAINER="zivgitlab.wwu.io/ag-ohlberger/dune-community/docker/${CONTAINER}"
fi
PROJECT=${2}
shift 2
CID_FILE=${BASEDIR}/.${PROJECT}-${CONTAINER//\//_}.cid
PORT="18$(( ( RANDOM % 10 ) ))$(( ( RANDOM % 10 ) ))$(( ( RANDOM % 10 ) ))"
DOCKER_HOME=${HOME}/.docker-homes/${SYSTEM}
DOCKER_BIN=${DOCKER:-docker}

if [[ ${DOCKER_BIN::5} == "sudo " ]]; then
  LOCAL_USER=$USER
  LOCAL_UID=$(id -u)
  LOCAL_GID=$(id -g)
  TARGET_HOME=/home/${USER}
else
  LOCAL_USER=root
  LOCAL_UID=0
  LOCAL_GID=0
  TARGET_HOME=/root
fi

if [ -e ${CID_FILE} ]; then

  echo "A docker container for"
  echo "  ${PROJECT}"
  echo "  based on ${CONTAINER}"
  echo "is already running. Execute the following command to connect to it"
  echo "(docker_exec.sh is provided alongside this file):"
  echo "  docker_exec.sh ${CONTAINER} ${PROJECT} ${@}"
  echo "If you are absolutely certain that there is no running container"
  echo "(check with '${DOCKER_BIN} ps' and stop it otherwise), you may"
  echo "  rm $CID_FILE"
  echo "and try again."

else

  echo "Starting a docker container"
  echo "  for ${PROJECT}"
  echo "  based on ${CONTAINER}"
  echo "  on port $PORT"

  mkdir -p ${DOCKER_HOME} &> /dev/null

  ${DOCKER_BIN} run --rm=true --privileged=true -t -i --hostname docker --cidfile=${CID_FILE} \
    -e LOCAL_USER=$LOCAL_USER -e LOCAL_UID=$LOCAL_UID -e LOCAL_GID=$LOCAL_GID \
    -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e QT_X11_NO_MITSHM=1 \
    -e QT_SCALE_FACTOR=${QT_SCALE_FACTOR:-1} \
    -e GDK_DPI_SCALE=${GDK_DPI_SCALE:-1} \
    -e EXPOSED_PORT=$PORT -p $PORT:$PORT \
    -v /etc/localtime:/etc/localtime:ro \
    -v $DOCKER_HOME:$TARGET_HOME \
    -v ${BASEDIR}/${PROJECT}:$TARGET_HOME/${PROJECT} \
    ${CONTAINER} "${@}"

  rm -f ${CID_FILE}

  if [ -d $DOCKER_HOME/${PROJECT} ]; then
    [ "$(ls -A $DOCKER_HOME/${PROJECT})" ] || rmdir $DOCKER_HOME/${PROJECT}
  fi

fi
