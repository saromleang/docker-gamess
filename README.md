# docker-gamess
Deployment of the General Atomic and Molecular Electronic Structure System (GAMESS) quantum chemistry code via a Docker container.

**Requirements:**
- Docker (download and install): https://www.docker.com/products/docker#/
- GAMESS public release tarball gamess.tar.gz: http://www.msg.ameslab.gov/gamess/download.html

**Installation:**

0. Open up a terminal window.
1. Clone/download the docker-gamess repository:

   ```
   git clone https://github.com/saromleang/docker-gamess.git docker-gamess
   ```
2. Place a copy the GAMESS public release **gamess.tar.gz** into the **docker-gamess** folder that was just created.
3. Navigate into the **docker-gamess** folder:

   ```
   cd docker-gamess
   ```
4. Build the image:

   without ATLAS math library:
   ```
   docker build -t docker-gamess:public .
   ```
   with ATLAS math library (Warning! Long build time):
   ```
   docker build -t docker-gamess:public --buildarg BLAS=atlas .
   ```
5. Verify the image **docker-gamess:public** is available to run:

   ```
   docker images
   ```
   You should see:

   <pre>REPOSITORY          TAG</br>
   docker-gamess       public</pre>
   
   
