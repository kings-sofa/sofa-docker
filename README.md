# Sofa-Docker

This is just a tutorial on how to run my precompiled custom version of Sofa inside a Docker container.

## How to create a Docker conatiner

In order to have a shared platform for testing, I have created a custom Docker container to compile SOFA with the most commonly used plugins in the lab (SoftRobots, SofaPython3, SofaCUDA and BeamAdapter). You can read more about Dockers [here](https://docs.docker.com/get-started/overview/). To install Docker follow the instructions in the official [website](https://docs.docker.com/get-docker/). On one hand, you could build your own custom sofa docker image starting from the [sofa-builder](https://hub.docker.com/r/sofaframework/sofabuilder_ubuntu) present in the official documentation. On the other hand you could directly download the already precompiled docker container from my account at [DockerHub](https://hub.docker.com/) official website. Use the following commands for that.

```bash
docker pull mikelitu/sofa-docker:latest
```

## Running the Docker container with GUI capabilities

In order to have GUI capabilities inside Docker we have two different options. The first one is the simplest one, but it is usually the least secure of all the approaches. We will allow the Docker container to use the host's X11 socket.

```bash
xhost local:root
docker run -it --net=host \
--env="DISPLAY" \
--env="QT_X11_NO_MITSMH=1" \
--env="QTWEBENGINE_DISABLE_SANDBOX=1" \
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
mikelitu/sofa-docker:latest
```

However this method is not bulletproof and may cause problems sometimes. The best method is to use NVIDIA drivers (only works with NVIDIA GPUs) with the NVIDIA Container Toolkits. To use it we first need to install the dependencies using the following command.

```bash
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list |sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
```

This method requires the use of the proper NVIDIA drivers, which can be a bit tricky in Ubuntu, but it is much more secure and you should have them if you are using CUDA, than the previous method. For this run the following command. 

```bash
xhost local:root
docker run -it --net=host --gpus=all \ 
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="DISPLAY" --env="QT_X11_NO_MITSHM=1" \ 
--env="QTWEBENGINE_DISABLE_SANDBOX=1" \ 
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \ 
mikelitu/sofa-docker:latest
```

You can run the command `nvidia-smi` inside the container to check that you have access to your computer GPU. With this you should be able to use the SofaCUDA plugin inside the container. 

## Running the Docker with the Touch X device

If we want to use the haptic device inside the Docker container we have two different options. We can include direct access to the device using the *--device* command when creating the container or we can create a shared volume between the local machine and the virtual environment in the container. Here are the two different examples.

```bash
xhost local:root
docker run -it --net=host \ 
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="DISPLAY" --env="QT_X11_NO_MITSHM=1" \ 
--env="QTWEBENGINE_DISABLE_SANDBOX=1" \ 
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--device=/dev/ttyACM0 \ 
mikelitu/sofa-docker:latest
```
or
```bash
xhost local:root
docker run -it --net=host \ 
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="DISPLAY" --env="QT_X11_NO_MITSHM=1" \ 
--env="QTWEBENGINE_DISABLE_SANDBOX=1" \ 
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume=/dev/ttyACM0:/dev/Geomagic \ 
mikelitu/sofa-docker:latest
```

You can now run the Docker container with the Geomagic device connected inside. (This part has not been tested already, but I should do it soon).

## How to containarize applications
The last part to use the Docker is how to transform the isolated simulation and the system into a complete application for deployment using the already pre-built sofa docker. We have two different options here: we can either share the volume where we have our simulation scene, so it is available inside the container or we could containerize the simulation copying the directory inside the container and freeze it there for automatic launching when running the container.

Here is a small example on how to create this volume to run and debug the code inside the container. 

```bash
xhost local:root
docker run -it --net=host \ 
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="DISPLAY" --env="QT_X11_NO_MITSHM=1" \ 
--env="QTWEBENGINE_DISABLE_SANDBOX=1" \ 
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume="~/your_project:/your_project" 
mikelitu/sofa-docker:latest
# ./build/bin/runSofa your_project/scene.py
```

For the other method I recommend creating a new Dockerfile base on the template in this repository. You can make any additional changes on the file you need for your project. This will let us control the dependencies and we can add additional python libraries to run our scene. Now rebuilt your new docker image with the requirements and custom conda environment and run it with the same command used before.

```bash
docker build --tag your_name/sofa-docker:custom .
xhost local:root
docker run -it --net=host \ 
--env="NVIDIA_DRIVER_CAPABILITIES=all" \
--env="DISPLAY" --env="QT_X11_NO_MITSHM=1" \ 
--env="QTWEBENGINE_DISABLE_SANDBOX=1" \ 
--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
--volume="~/your_project:/your_project" 
your_name/sofa-docker:custom python3 your_project/scene.py
```
## Authors and acknowledgment
Mikel De Iturrate Reyzabal (King's College London)
