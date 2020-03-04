.PHONY: default build publish

DOCKER_IMAGE_NAME=twuni/nodejs
NODEJS_MAJOR_VERSION=12

NPM_VERSION=$(shell npm view npm version)
NODEJS_VERSION=$(shell asdf list-all nodejs | grep -E "^$(NODEJS_MAJOR_VERSION)\." | tail -1)
YARN_VERSION=$(shell asdf list-all yarn | tail -1)

default: build

build:
	docker build \
	  --build-arg NODEJS_VERSION=$(NODEJS_VERSION) \
	  --build-arg NPM_VERSION=$(NPM_VERSION) \
	  --build-arg YARN_VERSION=$(YARN_VERSION) \
	  --tag $(DOCKER_IMAGE_NAME):$(NODEJS_VERSION) \
	  .

publish:
	docker push $(DOCKER_IMAGE_NAME):$(NODEJS_VERSION)
