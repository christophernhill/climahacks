# Build using
#  docker build -t clima -f CLIMA.dockerfile .

# Typical run command
#  docker run -d -v `pwd`:/home/jlab/host -P -i -t --rm clima /bin/bash

# FROM julia@sha256:c13bc0b99ab003de993078fdf70481bc0fd500ebf1d38968d89d32db6905a446
FROM julia:latest

RUN apt-get update && apt-get install -y gfortran mpich libmpich-dev less vim wget bzip2 procps git net-tools screen cmake ffmpeg xorg-dev sudo

RUN ( adduser --disabled-password --shell /bin/bash --gecos "User" juser; usermod -aG sudo juser; passwd -d juser )

USER juser
RUN ( cd /home/juser; wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh )
RUN ( cd /home/juser; chmod +x  ./Miniconda3-latest-Linux-x86_64.sh; ./Miniconda3-latest-Linux-x86_64.sh -b -p `pwd`/miniconda3 )
RUN ( cd /home/juser; export PATH="`pwd`/miniconda3/bin:$PATH"; conda create -y -n myconda -c conda-forge python=3.6 dask distributed xarray jupyterlab mpi4py matplotlib basemap pillow mayavi )
RUN ( cd /home/juser; export PATH="`pwd`/miniconda3/bin:$PATH"; /bin/bash -c "source activate myconda; julia -e 'using Pkg;Pkg.add(\"IJulia\");using IJulia'" )

EXPOSE 8888

ENV JROOT=/home/juser
ENV CGIT=https://github.com/climate-machine/CLIMA.git
ENV CC=/usr/bin/mpicc
ENV CXX=/usr/bin/mpicxx
ENV FC=/usr/bin/mpif90
CMD ( cd ${JROOT} ; git clone ${CGIT}; export PATH="`pwd`/miniconda3/bin:$PATH"; /bin/bash -c "source activate myconda; cd host; jupyter lab --ip `hostname -I` --allow-root" )
