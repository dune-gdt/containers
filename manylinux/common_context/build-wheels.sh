#!/bin/bash -l
set -exu

md=${1}
shift

cd ${DUNE_SRC_DIR}

# why was this here again?
rm -rf dune-uggrid dune-testtools

OPTS=${DUNE_SRC_DIR}/config.opts/manylinux

# sets Python path, etc.
source /usr/local/bin/pybin.sh
export CCACHE_DIR=${WHEEL_DIR}/../cache
mkdir ${WHEEL_DIR}/{tmp,final} -p || true

cd ${DUNE_SRC_DIR}
if [[ "${md}" == "all" ]] ; then
  ./dune-common/bin/dunecontrol --opts=${OPTS} configure
  ./dune-common/bin/dunecontrol --opts=${OPTS} bexec ninja -d explain -j $(nproc --ignore 1) -l $(nproc --ignore 1)
elif [[ -d dune-${md} ]] ; then
  ./dune-common/bin/dunecontrol --only=dune-${md} --opts=${OPTS} bexec ninja -d explain -j $(nproc --ignore 1) -l $(nproc --ignore 1) bindings
  python -m pip wheel ${DUNE_BUILD_DIR}/dune-${md}/python -w ${WHEEL_DIR}/tmp
  # Bundle external shared libraries into the wheels
  for whl in $(ls ${WHEEL_DIR}/tmp/dune_${md}*.whl); do
      # but only in the freshly built wheels, not the downloaded dependencies
      [[ $whl == *"manylinux"* ]] || \
          python -m auditwheel repair --plat ${PLATFORM} $whl -w ${WHEEL_DIR}/final
  done
  # install wheel to be available for other modules
  pip install ${WHEEL_DIR}/final/dune_${md}*.whl
else
  # this covers the case where the container is run with an additional ${EXEC} via 
  # the make_dockerwheels.bash script from the dune-gdt-super module
  exec "${md}"
fi
