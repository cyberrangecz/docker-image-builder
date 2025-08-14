# Docker Image Builder

This repository contains definition of a Docker image with QEMU, Packer, Ansible and OpenTofu.

## Example usage
```bash
# build
sudo docker build - < Dockerfile -t packer:latest

# run
sudo docker run --rm -it --privileged --network=host -w /opt -v `pwd`:/opt packer
```

## License
This project is licensed under the [MIT License](LICENSE).
