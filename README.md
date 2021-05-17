# Docker Image Builder

This repository contains definition of a Docker image with QEMU, VBox, Packer, Vagrant, OpenStack-cli and Ansible, which is used in [ci-cd-virtual-images](https://gitlab.ics.muni.cz/muni-kypo-images/ci-cd-virtual-images).

The Docker image is also available on [Docker Hub](https://hub.docker.com/repository/docker/munikypo/packer-vbox-qemu).

## Example usage
```bash
# build
sudo docker build - < Dockerfile -t packer:latest

# run
sudo docker run --rm -it --privileged --network=host -w /opt -v `pwd`:/opt packer
```

## License

This project is licensed under the [MIT License](LICENSE).
