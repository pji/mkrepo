#! /bin/bash

#####
# mkpy.sh: Build directory structure for a Python project
# Paul J. Iutzi
# 2021.8.16
# v 0.3
#   * Added venv
#   * Added precommit.py
#
# v 0.4
#   * Added text to README.rst
#   * Added text to LICENCE
#   * Added activation of venv
#
# v 0.5
#   * Added docs/requirements.rst
#
# v 0.6
#   * Added pre-commit hook
#   * Added branch rename
#
#####

# Location
ROOT=`pwd`
BASE=`basename ${ROOT}`

echo "Building ${BASE} in ${ROOT}"

# Build root files
touch ${ROOT}/README.rst
touch ${ROOT}/setup.py
touch ${ROOT}/requirements.txt
touch ${ROOT}/.gitignore

# Populate README.rst
LINE=$(echo -n ${BASE} | tr -c '' '[#*]')
echo ${LINE} >> ${ROOT}/README.rst
echo ${BASE} >> ${ROOT}/README.rst
echo ${LINE} >> ${ROOT}/README.rst

# Populate .gitignore
echo "# Ignore compiled files." >> ${ROOT}/.gitignore
echo "*.pyc" >> ${ROOT}/.gitignore
echo "*__pycache__" >> ${ROOT}/.gitignore
echo "" >> ${ROOT}/.gitignore
echo "# Ignore virtual environment." >> ${ROOT}/.gitignore
echo ".venv" >> ${ROOT}/.gitignore

# Populate python precommit script
cp ~/Dev/mkrepo/precommit.py ${ROOT}/

# Populate licence
cp ~/Dev/mkrepo/LICENSE ${ROOT}/

# Build module
mkdir ${ROOT}/${BASE}
touch ${ROOT}/${BASE}/__init__.py
touch ${ROOT}/${BASE}/__version__.py
touch ${ROOT}/${BASE}/${BASE}.py

# Populate __version__.py
LINE=$(echo -n __version__ | tr -c '' '[~*]')
DATE=$(date +'%Y')
echo '"""' >> ${ROOT}/${BASE}/__version__.py
echo '__version__' >> ${ROOT}/${BASE}/__version__.py
echo '~~~~~~~~~~~' >> ${ROOT}/${BASE}/__version__.py
echo '' >> ${ROOT}/${BASE}/__version__.py
echo 'Common information, including the version number.' >> ${ROOT}/${BASE}/__version__.py
echo '"""' >> ${ROOT}/${BASE}/__version__.py
echo '' >> ${ROOT}/${BASE}/__version__.py
echo "__title__ = '"${BASE}"'" >> ${ROOT}/${BASE}/__version__.py
echo "__description__ = ''" >> ${ROOT}/${BASE}/__version__.py
echo "__version__ = '0.0.1-dev'" >> ${ROOT}/${BASE}/__version__.py
echo "__author__ = 'Paul J. Iutzi'" >> ${ROOT}/${BASE}/__version__.py
echo "__license__ = 'MIT'" >> ${ROOT}/${BASE}/__version__.py
echo "__copyright__ = 'Copyright (c) "${DATE}" Paul J. Iutzi'" >> ${ROOT}/${BASE}/__version__.py

# Populate the core file
LINE=$(echo -n ${BASE} | tr -c '' '[~*]')
echo '"""' >> ${ROOT}/${BASE}/${BASE}.py
echo ${BASE} >> ${ROOT}/${BASE}/${BASE}.py
echo ${LINE} >> ${ROOT}/${BASE}/${BASE}.py
echo '"""' >> ${ROOT}/${BASE}/${BASE}.py

# Build docs
mkdir ${ROOT}/docs
touch ${ROOT}/docs/requirements.rst

# Populate requirements.rst
LINE=$(echo -n ${BASE}\ Requirements | tr -c '' '[#*]')
echo ${LINE} >> ${ROOT}/docs/requirements.rst
echo ${BASE}\ Requirements >> ${ROOT}/docs/requirements.rst
echo ${LINE} >> ${ROOT}/docs/requirements.rst

# Build tests
mkdir ${ROOT}/tests
touch ${ROOT}/tests/test_${BASE}.py
LINE=$(echo -n test_${BASE} | tr -c '' '[~*]')
echo '"""' >> ${ROOT}/tests/test_${BASE}.py
echo test_${BASE} >> ${ROOT}/tests/test_${BASE}.py
echo ${LINE} >> ${ROOT}/tests/test_${BASE}.py
echo '"""' >> ${ROOT}/tests/test_${BASE}.py
echo 'import unittest as ut' >> ${ROOT}/tests/test_${BASE}.py


# Create virtual environment
python3 -m venv ${ROOT}/.venv

# Add to the git branch
git init
git branch -m 'main'
git add ${ROOT}/README.rst
git add ${ROOT}/LICENSE
git add ${ROOT}/setup.py
git add ${ROOT}/requirements.txt
git add ${ROOT}/${BASE}
git add ${ROOT}/.gitignore
git add ${ROOT}/precommit.py
cp ~/Dev/mkrepo/pre-commit ${ROOT}/.git/hooks
chmod +x ${ROOT}/.git/hooks

# Set up pip and pipenv
source ${ROOT}/.venv/bin/activate
pip install --upgrade pip
pip install pipenv

# Set up basic dev dependencies
pipenv install -d pycodestyle
pipenv install -d mypy
pipenv install -d rstcheck

echo "Build complete."
echo "To start virtual environment:"
echo "source ${ROOT}/.venv/bin/activate"

