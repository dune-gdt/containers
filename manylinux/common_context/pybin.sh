#!/bin/sh

PYVER=${PY_SHORT}
export PYVER
PYTHON_ROOT_DIR=/opt/python/${PYVER}
export PYTHON_ROOT_DIR
PYBIN=${PYTHON_ROOT_DIR}/bin
export PATH=${PYBIN}:${PATH}
