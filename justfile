set positional-arguments

export GID := `id -g`
export UID := `id -u`

default:
  just --list

# Build the docker image
build:
  docker compose build --build-arg APP_UID="$(id -u)" --build-arg APP_GID="$(id -g)"

# Access a running docker container
exec *args="bash":
  docker compose exec lab "$@"

readme:
  glow README.md

# Run a shell in a new container
run *args="bash":
  docker compose run lab "$@"

# Test to see if your GPU is correctly connected to docker
test-gpu:
  docker compose run lab python3 -c 'import torch; torch.cuda.is_available()'

# Start the docker container
up *args:
  docker compose up "$@"
