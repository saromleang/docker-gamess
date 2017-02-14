# docker-gamess
Deployment of the General Atomic and Molecular Electronic Structure System (GAMESS) quantum chemistry code via a Docker container.

**Requirements:**
- Docker (download and install): https://www.docker.com/products/docker#/
- GAMESS public release tarball gamess.tar.gz: http://www.msg.ameslab.gov/gamess/download.html

**Installation:**

1. Open up a terminal window.
2. Clone/download the docker-gamess repository:

   ```
   git clone https://github.com/saromleang/docker-gamess.git docker-gamess
   ```
3. Place a copy the GAMESS public release **gamess.tar.gz** into the **docker-gamess** folder that was just created.
4. Navigate into the **docker-gamess** folder:

   ```
   cd docker-gamess
   ```
5. Build the image (choose with or without the ATLAS math library):

   without ATLAS math library:
   ```
   docker build -t docker-gamess:public .
   ```
   with ATLAS math library (Warning! Long build time):
   ```
   docker build -t docker-gamess:public --buildarg BLAS=atlas .
   ```
6. Verify the image **docker-gamess:public** is available to run:

   ```
   docker images
   ```
   You should see:

   <pre><strong>REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE</strong>
docker-gamess       public-atlas        xxxxxxxxxxxx        About an hour ago   630 MB</pre>

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
  
  ```-v /path/to/docker-gamess:/home/gamess``` binds the volume **/path/to/docker-gamess** on the host over to **/home/gamess** on the container
  
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
  
