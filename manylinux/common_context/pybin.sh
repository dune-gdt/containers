#!/bin/sh

PYVER=$(python3.9 -c 'pyversions={"3.7":"cp37-cp37m", "3.5":"cp35-cp35m", "3.6":"cp36-cp36m"}\
    ;pyversions.update({f"3.{i}": f"cp3{i}-cp3{i}" for i in range(8,18)});import os;print(pyversions[os.environ["PYTHON_VERSION"]])')
export PYVER
PYTHON_ROOT_DIR=/opt/python/${PYVER}
export PYTHON_ROOT_DIR
PYBIN=${PYTHON_ROOT_DIR}/bin
export PATH=${PYBIN}:${PATH}
