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
#
# v0.12
#   * Upgraded to Python 3.11.0
#   * Added Makefile
#   * Added readthedocs.yaml
#   * Moved setuptools config to pyproject.toml
#   * Added sphinx and sphinx docs structure
#
# v0.13
#   * Move to use pytest.
#   * Moved to Python 3.12.0.
#   * Moved project into src directory.
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
cp ~/Dev/mkrepo/Makefile ${ROOT}/
cp ~/Dev/mkrepo/readthedocs.yaml ${ROOT}/

# Populate README.rst
LINE=$(echo -n ${BASE} | tr -c '' '[#*]')
echo ${LINE} >> ${ROOT}/README.rst
echo ${BASE} >> ${ROOT}/README.rst
echo ${LINE} >> ${ROOT}/README.rst

# Populate .gitignore
echo "# Ignore compiled files." >> ${ROOT}/.gitignore
echo "*.pyc" >> ${ROOT}/.gitignore
echo "*__pycache__" >> ${ROOT}/.gitignore
echo "/build" >> ${ROOT}/.gitignore
echo "/dist" >> ${ROOT}/.gitignore
echo "*.egg-info" >> ${ROOT}/.gitignore
echo "" >> ${ROOT}/.gitignore
echo "# Ignore virtual environment." >> ${ROOT}/.gitignore
echo ".venv" >> ${ROOT}/.gitignore
echo "" >> ${ROOT}/.gitignore
echo "# Ignore OS/IDE files." >> ${ROOT}/.gitignore
echo ".DS_Store" >> ${ROOT}/.gitignore
echo "*BBEdit*" >> ${ROOT}/.gitignore
echo ".idea" >> ${ROOT}/.gitignore

# Populate python precommit script
cp ~/Dev/mkrepo/precommit.py ${ROOT}/

# Populate licence
cp ~/Dev/mkrepo/LICENSE ${ROOT}/

# Build module
mkdir ${ROOT}/src/${BASE}
mkdir ${ROOT}/src/${BASE}
touch ${ROOT}/src/${BASE}/__init__.py
touch ${ROOT}/src/${BASE}/${BASE}.py

# Populate the core file
LINE=$(echo -n ${BASE} | tr -c '' '[~*]')
echo '"""' >> ${ROOT}/src/${BASE}/${BASE}.py
echo ${BASE} >> ${ROOT}/src/${BASE}/${BASE}.py
echo ${LINE} >> ${ROOT}/src/${BASE}/${BASE}.py
echo '"""' >> ${ROOT}/src/${BASE}/${BASE}.py

# Build docs
mkdir ${ROOT}/docs
mkdir ${ROOT}/docs/source
touch ${ROOT}/docs/source/requirements.rst
cp ~/Dev/mkrepo/conf.py ${ROOT}/docs/source/

# Populate requirements.rst
LINE=$(echo -n ${BASE}\ Requirements | tr -c '' '[#*]')
echo ${LINE} >> ${ROOT}/docs/source/requirements.rst
echo ${BASE}\ Requirements >> ${ROOT}/docs/source/requirements.rst
echo ${LINE} >> ${ROOT}/docs/source/requirements.rst

# Build tests
mkdir ${ROOT}/tests
touch ${ROOT}/tests/test_${BASE}.py
LINE=$(echo -n test_${BASE} | tr -c '' '[~*]')
echo '"""' >> ${ROOT}/tests/test_${BASE}.py
echo test_${BASE} >> ${ROOT}/tests/test_${BASE}.py
echo ${LINE} >> ${ROOT}/tests/test_${BASE}.py
echo '"""' >> ${ROOT}/tests/test_${BASE}.py

# Create virtual environment
# Since Homebrew's location can move around, it's location must be
# defined as an environment variable for this script to work.
if [[ -z "$HOMEBREW_CELLAR" ]]; then
    echo "HOMEBREW_CELLAR must be defined." 1>&2
    exit 1
fi
${HOMEBREW_CELLAR}/python@3.12/3.12.0/bin/python3.12 -m venv ${ROOT}/.venv

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
pipenv install -d sphinx
pipenv install -d furo
pipenv install -d pycodestyle
pipenv install -d mypy
pipenv install -d rstcheck[sphinx]
pipenv install -d pytest
pipenv install -d isort
pipenv install -d tox
pipenv install -d wheel
pipenv install -d build
pipenv install -d twine

echo "Build complete."
echo "To start virtual environment:"
echo "source ${ROOT}/.venv/bin/activate"
