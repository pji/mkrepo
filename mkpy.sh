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
# v 0.7
#   * Converted to using pipenv for managing dependencies
#   * Moved precommit.py config into the setup.cfg file
#
# v 0.8
#   * Moved to Python 3.10
#   * Moved packaging setup to setup.cfg
#   * Added packaging and build requirements
#
# v 0.9
#   * Moved location of the homebrew Cellar.
#
# v0.10
#   * Checks to make sure the HOMEBREW_CELLAR environment variable is
#     set before building the virtual environment.
#
# v0.11
#   * Switched from using setup.py to pyproject.toml.
#####

# Location
ROOT=`pwd`
BASE=`basename ${ROOT}`

echo "Building ${BASE} in ${ROOT}"

# Build root files
touch ${ROOT}/README.rst
touch ${ROOT}/requirements.txt
touch ${ROOT}/.gitignore
cp ~/Dev/mkrepo/setup.cfg ${ROOT}/
cp ~/Dev/mkrepo/pyproject.toml ${ROOT}/

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
touch ${ROOT}/${BASE}/${BASE}.py

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
# Since Homebrew's location can move around, it's location must be
# defined as an environment variable for this script to work.
if [[ -z "$HOMEBREW_CELLAR" ]]; then
    echo "HOMEBREW_CELLAR must be defined." 1>&2
    exit 1
fi
${HOMEBREW_CELLAR}/python@3.10/3.10.6_1/bin/python3 -m venv ${ROOT}/.venv

# Add to the git branch
git init
git branch -m 'main'
git add ${ROOT}/README.rst
git add ${ROOT}/LICENSE
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
pipenv install -d wheel
pipenv install -d build
pipenv install -d twine

echo "Build complete."
echo "To start virtual environment:"
echo "source ${ROOT}/.venv/bin/activate"
