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
#
# v0.14
#   * Move to using poetry.
#
# v0.15 2025.11.4
#   * Use HOMEBREW_PREFIX to determine homebrew location.
#   * Add the poetry export plugin.
#   * Generates the initial requirements.txt file.
#   * Now checks if an argument was passed.
#   * Now checks if desired repo exists.
#####

# Make sure something was given as a parameter.
if [[ -z "$1" ]]; then
    echo 'Proper syntax: mkpy.sh <name_of_repo>'
    exit 0
fi

# Location
HOMEBREW=${HOMEBREW_PREFIX}/bin
BASE=$1
PARENT=`pwd`
ROOT=${PARENT}/${BASE}
MODBASE=`echo ${BASE} | sed -e 's/-/_/'`

# Make sure the root doesn't already exist.
if [[ -d ${ROOT} ]]; then
    echo "Path ${ROOT} already exists."
    exit 0
fi

echo "Building ${BASE} in ${ROOT}"

# Build core repo with poetry. Assumes poetry is available via homebrew.
${HOMEBREW}/poetry new ${BASE}

# Build root files
touch ${ROOT}/.gitignore
cp ~/Dev/mkrepo/setup.cfg ${ROOT}/
cp ~/Dev/mkrepo/Makefile ${ROOT}/
cp ~/Dev/mkrepo/readthedocs.yaml ${ROOT}/

# Populate README.md
LINE=$(echo -n ${BASE} | tr -c '' '[#*]')
echo ${LINE} >> ${ROOT}/README.md
echo ${BASE} >> ${ROOT}/README.md
echo ${LINE} >> ${ROOT}/README.md

# Update the files with the project name.
sed -i .bkp -e s/[{]PROJECT_NAME[}]/${MODBASE}/g ${ROOT}/Makefile
sed -i .bkp -e s/[{]PROJECT_NAME[}]/${MODBASE}/g ${ROOT}/setup.cfg
rm ${ROOT}/Makefile.bkp
rm ${ROOT}/setup.cfg.bkp

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
touch ${ROOT}/src/${MODBASE}/${MODBASE}.py

# Populate the core file
LINE=$(echo -n ${BASE} | tr -c '' '[~*]')
echo '"""' >> ${ROOT}/src/${MODBASE}/${MODBASE}.py
echo ${BASE} >> ${ROOT}/src/${MODBASE}/${MODBASE}.py
echo ${LINE} >> ${ROOT}/src/${MODBASE}/${MODBASE}.py
echo '"""' >> ${ROOT}/src/${MODBASE}/${MODBASE}.py

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
touch ${ROOT}/tests/test_${MODBASE}.py
LINE=$(echo -n test_${MODBASE} | tr -c '' '[~*]')
echo '"""' >> ${ROOT}/tests/test_${MODBASE}.py
echo test_${MODBASE} >> ${ROOT}/tests/test_${MODBASE}.py
echo ${LINE} >> ${ROOT}/tests/test_${MODBASE}.py
echo '"""' >> ${ROOT}/tests/test_${MODBASE}.py

# Create virtual environment
${HOMEBREW}/python3 -m venv ${ROOT}/.venv

# Set up pip and poetry
cd ${ROOT}
source ${ROOT}/.venv/bin/activate
pip install --upgrade pip
pip install poetry
poetry self add poetry-plugin-export

# Set up basic dev dependencies
poetry add --dev sphinx
poetry add --dev furo
poetry add --dev pycodestyle
poetry add --dev mypy
poetry add --dev rstcheck[sphinx]
poetry add --dev pytest
poetry add --dev isort
poetry add --dev tox
poetry add --dev wheel
poetry add --dev build
poetry add --dev twine

# Create the original requirements.txt file.
poetry export -f requirements.txt -o requirements.txt --without-hashes

# Add to the git branch
git init
git branch -m 'main'
git add ${ROOT}/README.md
git add ${ROOT}/LICENSE
git add ${ROOT}/Makefile
git add ${ROOT}/poetry.lock
git add ${ROOT}/pyproject.toml
git add ${ROOT}/readthedocs.yaml
git add ${ROOT}/setup.cfg
git add ${ROOT}/docs
git add ${ROOT}/src
git add ${ROOT}/tests
git add ${ROOT}/.gitignore
git add ${ROOT}/precommit.py
git add ${ROOT}/requirements.txt
cp ~/Dev/mkrepo/pre-commit ${ROOT}/.git/hooks
chmod +x ${ROOT}/.git/hooks

echo "Build complete."
echo "To start virtual environment:"
echo "source ${ROOT}/.venv/bin/activate"
