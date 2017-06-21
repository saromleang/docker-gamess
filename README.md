# docker-gamess
Deployment of the General Atomic and Molecular Electronic Structure System (GAMESS) quantum chemistry code via a Docker container.

**Requirements:**
- **Ubuntu 12.04 or higher**
- Docker (download and install): https://www.docker.com/products/docker#/

**Installation:**

1. Open up a terminal window.
2. Clone/download the docker-gamess repository:

   ```
   git clone https://github.com/saromleang/docker-gamess.git docker-gamess
   ```
3. Navigate into the **docker-gamess** folder:

   ```
   cd docker-gamess
   ```
4. Understand available build arguments:
   * Ubuntu release version. Optional. Default `16.04`
     
     `--build-arg IMAGE_VERSION=[12.04|14.04|15.10|16.04]`

   * Math library choice. Optional. Default `none`

     `--build-arg BLAS=[none|atlas]`

   * GAMESS weekly password for souce code download. Required. Available via email after [accepting GAMESS license agreement](http://www.msg.ameslab.gov/gamess/License_Agreement.html).

     `--build-arg WEEKLY_PASSWORD=password`

   * Reduce final image size. Optional. Default `true`

     `--build-arg REDUCE_IMAGE_SIZE=[true|false]`

5. Build the image (choose with or without the ATLAS math library):

   without ATLAS math library:
   ```
   docker build --no-cache=true -t docker-gamess:public --build-arg IMAGE_VERSION=16.04 --build-arg BLAS=none --build-arg REDUCE_IMAGE_SIZE=true --build-arg WEEKLY_PASSWORD=xxxxxx .
   ```
   with ATLAS math library (Warning! Long build time):
   ```
   docker build --no-cache=true -t docker-gamess:public --build-arg IMAGE_VERSION=16.04 --build-arg BLAS=atlas --build-arg REDUCE_IMAGE_SIZE=true --build-arg WEEKLY_PASSWORD=xxxxxx .
   ```
6. Verify the image **docker-gamess:public** is available to run:

   ```
   docker images
   ```
   You should see:

```
   REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
   docker-gamess       public              xxxxxxxxxxxx        About an hour ago   XXX MB
```

**Usage:**

*Overview:*
We will launch a container to perform a GAMESS calculation. The container will delete itself after the run is completed. Log files and restart files will be retained by mapping a host folder to the container.

1.  Execute the following commanded to perform a GAMESS run on 1 cpu:

  ```
  docker run --rm -v /path/to/docker-gamess:/home/gamess docker-gamess:public X-0165-thymine-X.inp -p 1
  ```
  
  **Explaination:**
  
  ```docker run``` runs a command in a new container
  
  ```--rm``` automatically remove the container when it exits
  
  ```-v /path/to/docker-gamess:/home/gamess``` binds the volume **/path/to/docker-gamess** from the host over to **/home/gamess** on the container
  
  ```docker-gamess:public``` image name:image tag
  
  ```X-0165-thymine-X.inp``` the input file
  
  ```-p 1``` peform the calculation using 1 GAMESS compute process
  
   **Expected output:**

   <pre>
[Running input X-0165-thymine-X on 1 core(s)]
   o
  o                  ##        .
    o          ## ## ##       ==
   o        ## ## ## ##      ===
     o  /""""""""""""""""\\\___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \\\______ o          __/         
         \\\    \\\        __/          
          \\\____\\\______/             


    [Run completed]
   o
  o                  ##        .
    o          ## ## ##       ==
   o        ## ## ## ##      ===
     o  /""""""""""""""""\\\___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \\\______ o          __/         
         \\\    \\\        __/          
          \\\____\\\______/             
   </pre>
  
   The log file: **X-0165-thymine-X.log** will be located in **/path/to/docker-gamess** and all restart and scratch files will be located in  **/path/to/docker-gamess/restart** and **/path/to/docker-gamess/scratch**, respectively.

2. Remove the .dat file from the previous run:

   ```
   rm restart/X-0165-thymine-X.dat
   ```

3. Execute the following command to perform a GAMESS run on 2 cpus using sockets:

  ```
  docker run --rm -v /path/to/docker-gamess:/home/gamess docker-gamess:public X-0165-thymine-X.inp -p 2
  ```

4.  Execute the following command to output the syntax for running GAMESS on Docker:

   ```
   docker run --rm docker-gamess:public help
   ```
