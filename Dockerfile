# Base image heroku cedar stack v14
FROM heroku/cedar:14


# Make folder structure
RUN mkdir /emo-detect1
RUN mkdir /emo-detect1/.heroku
RUN mkdir /emo-detect1/.heroku/vendor
ENV LD_LIBRARY_PATH /emo-detect1/.heroku/vendor/lib/


# Install ATLAS with LAPACK and BLAS
WORKDIR /emo-detect1/.heroku
RUN apt-get update
RUN apt-get install -y gfortran
RUN curl -s -L http://www.netlib.org/lapack/lapack-3.6.1.tgz > lapack-3.6.1.tgz
RUN curl -s -L http://netix.dl.sourceforge.net/project/math-atlas/Stable/3.10.3/atlas3.10.3.tar.bz2 > /emo-detect1/.heroku/atlas3.10.3.tar.bz2
RUN bunzip2 -c atlas3.10.3.tar.bz2 | tar xfm -
RUN mkdir /emo-detect1/.heroku/ATLAS/Linux_C2D64SSE3
WORKDIR /emo-detect1/.heroku/ATLAS/Linux_C2D64SSE3
RUN ../configure -b 64 -D c -DPentiumCPS=2400 \
     --prefix=/emo-detect1/.heroku/vendor/ \
     --with-netlib-lapack-tarfile=/emo-detect1/.heroku/lapack-3.6.1.tgz
RUN make build && make check && make ptcheck && make time && make install
WORKDIR /emo-detect1/.heroku
RUN rm lapack-3.6.1.tgz
RUN rm atlas3.10.3.tar.bz2
RUN rm -r ATLAS
ENV ATLAS /emo-detect1/.heroku/vendor/lib/libatlas.a
ENV BLAS /emo-detect1/.heroku/vendor/lib/libcblas.a
ENV LAPACK /emo-detect1/.heroku/vendor/lib/liblapack.a


# Install Python 2.7.10
RUN apt-get remove -y python2.7
RUN apt-get remove -y python3.4
RUN apt-get remove -y python2.7-minimal
RUN apt-get remove -y python3.4-minimal
RUN apt-get remove -y libpython2.7-minimal
RUN apt-get remove -y libpython3.4-minimal

RUN curl -s -L http://kent.dl.sourceforge.net/project/tcl/Tcl/8.6.6/tcl8.6.6-src.tar.gz > tcl8.6.6-src.tar.gz
RUN tar -xvf tcl8.6.6-src.tar.gz
RUN rm tcl8.6.6-src.tar.gz
WORKDIR /emo-detect1/.heroku/tcl8.6.6/unix
RUN ./configure --prefix=/emo-detect1/.heroku/vendor/
RUN make && make install
WORKDIR /emo-detect1/.heroku/
RUN curl -s -L http://heanet.dl.sourceforge.net/project/tcl/Tcl/8.6.6/tk8.6.6-src.tar.gz > tk8.6.6-src.tar.gz
RUN tar -xvf tk8.6.6-src.tar.gz
RUN rm tk8.6.6-src.tar.gz
WORKDIR /emo-detect1/.heroku/tk8.6.6/unix
RUN ./configure --prefix=/emo-detect1/.heroku/vendor/ --with-tcl=/emo-detect1/.heroku/tcl8.6.6/unix
RUN make && make install
WORKDIR /emo-detect1/.heroku/
RUN rm -r tcl8.6.6
RUN rm -r tk8.6.6


RUN curl -s -L https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz > Python-2.7.10.tgz
RUN tar zxvf Python-2.7.10.tgz
RUN rm Python-2.7.10.tgz
WORKDIR /emo-detect1/.heroku/Python-2.7.10
RUN ./configure --prefix=/emo-detect1/.heroku/vendor/ --enable-shared --with-tcltk-includes="-I/emo-detect1/.heroku/vendor/include" --with-tcltk-libs="-L/emo-detect1/.heroku/vendor/lib -ltcl8.6.6 -L/emo-detect1/.heroku/vendor/lib -ltk8.6.6"
RUN make install
WORKDIR /emo-detect1/.heroku
RUN rm -rf Python-2.7.10
ENV PATH /emo-detect1/.heroku/vendor/bin:$PATH
ENV PYTHONPATH /emo-detect1/.heroku/vendor/lib/python2.7/site-packages


# Install latest setup-tools and pip
RUN curl -s -L https://bootstrap.pypa.io/get-pip.py > get-pip.py
RUN python get-pip.py
RUN rm get-pip.py


# Install Numpy
RUN pip install -v numpy==1.11.1


# Install Scipy
RUN pip install -v scipy==0.18.0


# Install Matplotlib
RUN pip install -v matplotlib==1.5.3


# Install Opencv with python bindings
RUN apt-get install -y cmake
RUN curl -s -L https://github.com/Itseez/opencv/archive/2.4.11.zip > opencv-2.4.11.zip
RUN unzip opencv-2.4.11.zip
RUN rm opencv-2.4.11.zip
WORKDIR /emo-detect1/.heroku/opencv-2.4.11
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/emo-detect1/.heroku/vendor -D BUILD_DOCS=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D BUILD_opencv_python=ON .
RUN make install
WORKDIR /emo-detect1/.heroku
RUN rm -rf opencv-2.4.11


# Create vendor package
WORKDIR /emo-detect1/
RUN tar cvfj /vendor.tar.bz2 .
VOLUME /vendoring
CMD cp /vendor.tar.bz2 /vendoring
