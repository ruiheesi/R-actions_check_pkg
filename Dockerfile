# Container image that runs the code
FROM ubuntu:20.04

RUN apt-get update \
  	&& apt-get install -y --no-install-recommends \
      ed \
      less \
      locales \
      vim-tiny \
      wget \
      ca-certificates \
      fonts-texgyre libx11-dev\
	  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
      software-properties-common \
      dirmngr \
	curl libcurl4-openssl-dev \
    && add-apt-repository --enable-source --yes "ppa:marutter/rrutter4.0" \
    && add-apt-repository --enable-source --yes "ppa:c2d4u.team/c2d4u4.0+"

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
#RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
#        && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default
#
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
      libx11-6 \
      libxss1 \
      libxt6 \
      libxext6 \
      libsm6 \
      libice6 \
      xdg-utils libxt-dev xorg-dev libcairo2 libcairo2-dev libpango1.0-dev \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update && \ 
	apt -y install zlib1g-dev
RUN apt-get update && \ 
	apt -y install libcurl4-openssl-dev \
                    libxml2-dev \
                    libssl-dev \
                    libpng-dev \
                    libhdf5-dev \
		    libquadmath0 \
		    libtiff5-dev \
		    libjpeg-dev \
		    libfreetype6-dev \
		    libgfortran5

ENV DEBIAN_FRONTEND=noninteractive

ENV R_BASE_VERSION 4.1.3



RUN apt-get update && \ 
	apt-get install -y --no-install-recommends \
                libopenblas0-pthread \
                r-base \
                r-base-dev \
                r-base-core \
                r-recommended

ENV RENV_VERSION 0.16.0

RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

ENV RENV_PATHS_LIBRARY renv/library


COPY renv.lock /renv.lock

RUN R -e 'renv::restore();renv::install("Biostrings@2.62.0");renv::install("Nanostring-Biostats/GeomxTools@326d969aa52ee2afb13fa49ca8df92b6306619da");renv::install("Nanostring-Biostats/SpatialDecon");renv::install("Nanostring-Biostats/SpatialOmicsOverlay")'


# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
