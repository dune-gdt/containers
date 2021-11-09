#!/bin/bash -l
set -exu

cd ${DUNE_SRC_DIR}

# why was this here again?
rm -rf dune-uggrid dune-testtools

OPTS=${DUNE_SRC_DIR}/config.opts/manylinux

# sets Python path, etc.
source /usr/local/bin/pybin.sh
export CCACHE_DIR=${WHEEL_DIR}/../cache
mkdir ${WHEEL_DIR}/{tmp,final} -p || true

cd ${DUNE_SRC_DIR}
./dune-common/bin/dunecontrol --opts=${OPTS} configure
./dune-common/bin/dunecontrol --opts=${OPTS} make -j $(nproc --ignore 1) -l $(nproc --ignore 1)

for md in xt gdt ; do
  if [[ -d dune-${md} ]]; then
    ./dune-common/bin/dunecontrol --only=dune-${md} --opts=${OPTS} make -j $(nproc --ignore 1) -l $(nproc --ignore 1) bindings
    python -m pip wheel ${DUNE_BUILD_DIR}/dune-${md}/python -w ${WHEEL_DIR}/tmp
    # Bundle external shared libraries into the wheels
    for whl in ${WHEEL_DIR}/tmp/dune-${md}*.whl; do
        # but only in the freshly built wheels, not the downloaded dependencies
        [[ $whl == *"manylinux"* ]] || \
            python -m auditwheel repair --plat ${PLATFORM} $whl -w ${WHEEL_DIR}/final
    done
    # install wheel into the dune-venv
    ./${DUNE_BUILD_DIR}/dune-common/run-in-dune-env pip install ${WHEEL_DIR}/final/dune-${md}*.whl
  fi
done
