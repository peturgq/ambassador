all: dev

VERSION=$(shell python scripts/versioner.py --magic-pre)

.ALWAYS:

dev: reg-check versions artifacts

reg-check:
	@if [ -z "$$DOCKER_REGISTRY" ]; then \
	    echo "DOCKER_REGISTRY must be set" >&2 ;\
	    exit 1 ;\
	fi

versions:
	@echo "Building $(VERSION)"
	for file in actl ambassador; do \
	    sed -e "s/{{VERSION}}/$(VERSION)/g" < VERSION-template.py > $$file/VERSION.py; \
	done

artifacts: docker-images yaml-files

yaml-files:
	VERSION=$(VERSION) sh scripts/build-yaml.sh

docker-images: ambassador-image statsd-image cli-image

ambassador-image: .ALWAYS
	scripts/docker_build_maybe_push ambassador $(VERSION) ambassador

statsd-image: .ALWAYS
	scripts/docker_build_maybe_push statsd $(VERSION) statsd

cli-image: .ALWAYS
	scripts/docker_build_maybe_push actl $(VERSION) actl

website: .ALWAYS
	VERSION=$(VERSION) docs/build-website.sh
