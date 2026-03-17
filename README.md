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
| Docker Options | `Apache Guacamole Desktop (VNC)\|localhost:8080:8080:/:Jupyter\|localhost:8080:8080:/terminals/1:Jupyter Terminal\|localhost:8384:18384:/:Syncthing" -e OPEN_BUTTON_PORT=1111 -e SELKIES_ENCODER=x264enc` |

