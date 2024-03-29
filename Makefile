.PHONY: build
build:
	sphinx-build -b html docs/source/ docs/build/html
	python -m build
	twine check dist/*

.PHONY: buildt
buildt:
	python -m pipenv install --dev -e .

.PHONY: clean
clean:
	rm -rf docs/build/html
	rm -rf dist
	rm -rf src/{PROJECT_NAME}.egg-info
	rm -rf src/{PROJECT_NAME}/__pycache__
	rm -rf src/{PROJECT_NAME}/*.pyc
	rm -rf examples/__pycache__
	rm -rf tests/__pycache__
	rm -rf thurible/__pycache__
	rm -f *.log
	python -m pipenv uninstall imgblender
	python -m pipenv install --dev -e .

.PHONY: docs
docs:
	sphinx-build -b html docs/source/ docs/build/html

.PHONY: pre
pre:
	python precommit.py
	git status

.PHONY: test
test:
	python -m pytest --capture=fd

.PHONY: testv
testv:
	python -m pytest -vv --capture=fd
