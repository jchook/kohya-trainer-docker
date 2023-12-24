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
  docker compose exec app "$@"

ss *args:
  docker compose exec app ./kohya_ss/gui.sh --server_port=7861 --listen=0.0.0.0 --headless "$@"

readme:
  glow README.md

# Run a shell in a new container
run *args="bash":
  docker compose run app "$@"

# Test to see if your GPU is correctly connected to docker
test-gpu:
  docker compose run app python3 -c 'import torch; torch.cuda.is_available()'

# Run jupyter lab instead of kohya_ss GUI
lab *args:
  docker compose -f docker-compose.lab.yml up "$@"

# Start the docker container
up *args:
  docker compose up "$@"
