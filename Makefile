PROJECT=oommfodt
IPYNBPATH=docs/ipynb/*.ipynb
CODECOVTOKEN=dee03a75-54f6-4959-8fe3-0ccf993a8374
PYTHON?=python3

test:
	$(PYTHON) -m pytest

# run test() function as users would
test-test:
	$(PYTHON) -c "import oommfodt as o; import sys; sys.exit(o.test())"

test-coverage:
	$(PYTHON) -m pytest --cov=$(PROJECT) --cov-config .coveragerc

test-ipynb:
	$(PYTHON) -m pytest --nbval $(IPYNBPATH)

test-docs:
	$(PYTHON) -m pytest --doctest-modules --ignore=$(PROJECT)/tests $(PROJECT)

test-all: test-test test-coverage test-ipynb test-docs

upload-coverage: SHELL:=/bin/bash
upload-coverage:
	bash <(curl -s https://codecov.io/bash) -t $(CODECOVTOKEN)

travis-build: SHELL:=/bin/bash
travis-build:
	ci_env=`bash <(curl -s https://codecov.io/env)`
	docker build -t dockertestimage .
	docker run -e ci_env -ti -d --name testcontainer dockertestimage
	docker exec testcontainer make test-all
	docker exec testcontainer make upload-coverage
	docker stop testcontainer
	docker rm testcontainer

test-docker:
	docker build -t dockertestimage .
	docker run -ti -d --name testcontainer dockertestimage
	docker exec testcontainer make test-all
	docker stop testcontainer
	docker rm testcontainer

build-dists:
	rm -rf dist/
	$(PYTHON) setup.py sdist
	$(PYTHON) setup.py bdist_wheel

release: build-dists
	twine upload dist/*
