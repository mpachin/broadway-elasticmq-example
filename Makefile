test-shell:
	docker compose \
		-f ./.devcontainer/docker-compose.test.yml \
		run --rm broadway-test /bin/sh

down:
	docker compose \
		-f ./.devcontainer/docker-compose.test.yml \
		down --remove-orphans
