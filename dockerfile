FROM nextflow/nextflow:24.04.4

# Install Python and pip
RUN yum install -y \
    python3 \
    python3-pip \
    make \
    gcc \
    zlib-devel \
    bzip2 \
    bzip2-devel \
    xz-devel \
    ncurses-devel \
    && yum clean all

# Install wget for downloading files (if not already included in your base image)
RUN yum install -y \
    wget \
    unzip \
    tar \
    && \
    yum clean all

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Set the virtual environment as the default Python environment
ENV PATH="/opt/venv/bin:$PATH"

# install numpy
RUN pip install \
    pandas \
    altair[all] \
    NanoPlot



SHELL ["/bin/bash", "-c"] 
    # Install samtools
RUN cd /opt \
&& wget https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2 \
&& tar -xjf samtools-1.20.tar.bz2 \
&& cd samtools-1.20 \
&& ./configure --prefix=/opt/venv \
&& make \
&& make install

# Install bcftools
RUN cd /opt \
&& wget https://github.com/samtools/bcftools/releases/download/1.20/bcftools-1.20.tar.bz2 \
&& tar -xjf bcftools-1.20.tar.bz2 \
&& cd bcftools-1.20 \
&& ./configure --prefix=/opt/venv \
&& make \
&& make install
 

RUN mkdir -p /opt/chopper && \
wget -O /opt/chopper/chopper-linux.zip https://github.com/wdecoster/chopper/releases/download/v0.8.0/chopper-linux.zip && \
unzip /opt/chopper/chopper-linux.zip -d /opt/chopper && \
chmod +x /opt/chopper/chopper && \
rm /opt/chopper/chopper-linux.zip

# Install minimap2
RUN cd /opt \
&& curl -L https://github.com/lh3/minimap2/releases/download/v2.28/minimap2-2.28_x64-linux.tar.bz2 | tar -jxvf - \
&& mv minimap2-2.28_x64-linux/minimap2 /opt/venv/bin/


# # Add chopper to PATH
# Add /opt/samtools/bin and /opt/bcftools/bin to PATH
ENV PATH="/opt/chopper:/opt/samtools/bin:/opt/bcftools/bin:$PATH"


WORKDIR "/mnt"