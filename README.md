Kohya Trainer Docker
====================

Dockerized
[Linaqruf/kohya-trainer](https://github.com/Linaqruf/kohya-trainer) so you can train dreambooth LoRAs and fine-tune Stable Diffusion models on your own hardware running Linux.


Features
--------

- [x] **Easy set-up** - One command to both install and launch.
- [x] **Easy config** - Manage your project on the host filesystem.
- [x] **Straightforward** - Nothing fancy. Default settings. Simple Dockerfile.
- [x] **Non-root** - Files are owned by your user. Nothing runs as root.
- [x] **Fast** - Start-up and shutdown are snappy.


Requirements
------------

- A Linux OS
- A recent Nvidia GPU
- docker
- docker-compose
- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)


How to Use
----------

Enjoy a streamlined experience with [`just`](https://github.com/casey/just):

```sh
just build
just up
```

Otherwise, you can use the standard docker tools as expected:

```sh
docker compose up
```

See Also
--------

- [jchook/stable-diffusion-webui-docker](https://github.com/jchook/stable-diffusion-webui-docker)
- [P2Enjoy/kohya_ss-docker](https://github.com/P2Enjoy/kohya_ss-docker)

