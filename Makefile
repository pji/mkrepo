.PHONY: build
build:
	sphinx-build -b html docs/source/ docs/build/html
	python -m build
	twine check dist/*

.PHONY: buildt
buildt:
	poetry install

.PHONY: clean
clean:
	rm -rf docs/build/html
	rm -rf dist
	rm -rf src/{PROJECT_NAME}.egg-info
	rm -rf src/{PROJECT_NAME}/__pycache__
	rm -rf src/{PROJECT_NAME}/*.pyc
	rm -rf examples/__pycache__
	rm -rf tests/__pycache__
	rm -f *.log

.PHONY: docs
docs:
	sphinx-build -b html docs/source/ docs/build/html

.PHONY: pre
pre:
	tox
	python -m pytest --doctest-modules src --capture=fd
	python precommit.py
	git status

.PHONY: test
test:
	python -m pytest --capture=fd
	python -m pytest --doctest-modules src --capture=fd

.PHONY: testv
testv:
	python -m pytest -vv --capture=fd
