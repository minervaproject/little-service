.PHONY: build run build-run

build-run: build run

build: Dockerfile.local
	git log -n 1 > last-commit.conf
	docker-compose build

run:
	docker-compose run --service-ports web
