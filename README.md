# rosmed-vastai-image


Buliding the Docker Image
-------------------------

The Dockerfile repository can be obtained by cloning the repository at GitHub. 

~~~
$ git clone https://github.com/rosmed/rosmed-vastai-image
$ cd rosmed-vastai-image
~~~

To build an image, run the following command:
~~~
$ docker build . -t rosmed/rosmed-vastai-image:ismr2026
~~~

To push the image to Docker Hub:
~~~
$ docker login -u <<myusername>> 
$ docker push rosmed/rosmed-vastai-image:ismr2026
~~~
NOTE: User `myusername` has to have write access for the repository.


Setting Up a vast.ai Template
-----------------------------

After logging in vast.ai, choose `Template` from the menu on the left side of the screen, and click the `New` button. The configuration should be as follows:

**Identification**

| Field                | Value                                                 |
|----------------------|-------------------------------------------------------|
| Template Name        | e.g., ROS-MED ISMR2026 Tutorial                       |
| Template Description | e.g., Linux desktop environment for ISMR2026 Tutorial |

**Docker Repository And Environment**

| Field          | Value                                                                                                                                                                                                                      |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Image Path:Tag | `rosmed/rosmed-vastai-image:ismr2026`                                                                                                                                                                                      |
| Docker Options | `-p 1111:1111 -p 6100:6100 -p 73478:73478 -p 8384:8384 -p 72299:72299 -p 6200:6200 -p 5900:5900 -e OPEN_BUTTON_TOKEN=1 -e JUPYTER_DIR=/ -e DATA_DIRECTORY=/workspace/ -e PORTAL_CONFIG="localhost:1111:11111:/:Instance Portal|localhost:6100:16100:/:Selkies Low Latency Desktop|localhost:6200:16200:/guacamole:Apache Guacamole Desktop (VNC)|localhost:8080:8080:/:Jupyter|localhost:8080:8080:/terminals/1:Jupyter Terminal|localhost:8384:18384:/:Syncthing" -e OPEN_BUTTON_PORT=1111 -e SELKIES_ENCODER=x264enc` |

