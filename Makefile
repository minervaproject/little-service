.PHONY: build run build-run

build-run: build run

build: Dockerfile.local
	docker-compose build

run:
	docker-compose run --service-ports web
