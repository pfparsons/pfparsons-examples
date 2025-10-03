
## Running containers with the NVIDIA Container Runtime

```shell
podman run -it --rm --device nvidia.com/gpu=all docker.io/nvidia/cuda:12.9.1-cudnn-devel-ubi9
```