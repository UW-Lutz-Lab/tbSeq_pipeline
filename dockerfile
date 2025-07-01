FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    make \
    gcc \
    zlib1g-dev \
    bzip2 \
    libbz2-dev \
    xz-utils \
    liblzma-dev \
    libncurses5-dev \
    libcurl4-openssl-dev \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    tar \
    python3-venv \
    curl \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Create a virtual environment
RUN python3 -m venv /opt/venv

# Set the virtual environment as the default Python environment
ENV PATH="/opt/venv/bin:$PATH"

# install numpy
RUN pip install \
    pandas \
    altair[all] \
    NanoPlot \
    kaleido==0.1.*

# Install Java (OpenJDK 17) and Nextflow
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -s https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/local/bin

# Install samtools
RUN cd /opt \
&& wget https://github.com/samtools/samtools/releases/download/1.22/samtools-1.22.tar.bz2 \
&& tar -xjf samtools-1.22.tar.bz2 \
&& cd samtools-1.22 \
&& ./configure --prefix=/opt/venv \
&& make \
&& make install

# Install bcftools
RUN cd /opt \
&& wget https://github.com/samtools/bcftools/releases/download/1.22/bcftools-1.22.tar.bz2 \
&& tar -xjf bcftools-1.22.tar.bz2 \
&& cd bcftools-1.22 \
&& ./configure --prefix=/opt/venv \
&& make \
&& make install
 

RUN mkdir -p /opt/chopper && \
wget -O /opt/chopper/chopper-linux.zip https://github.com/wdecoster/chopper/releases/download/v0.8.0/chopper-linux.zip && \
unzip /opt/chopper/chopper-linux.zip -d /opt/chopper && \
chmod +x /opt/chopper/chopper && \
rm /opt/chopper/chopper-linux.zip

# # Add chopper to PATH
# Add /opt/samtools/bin and /opt/bcftools/bin to PATH
ENV PATH="/opt/chopper:/opt/samtools/bin:/opt/bcftools/bin:$PATH"

# Install minimap2
RUN cd /opt \
&& curl -L https://github.com/lh3/minimap2/releases/download/v2.28/minimap2-2.28_x64-linux.tar.bz2 | tar -jxvf - \
&& mv minimap2-2.28_x64-linux/minimap2 /opt/venv/bin/

# Install bowtie2
RUN cd /opt && \
    wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.5.3/bowtie2-2.5.3-linux-x86_64.zip && \
    unzip bowtie2-2.5.3-linux-x86_64.zip && \
    mv bowtie2-2.5.3-linux-x86_64 bowtie2 && \
    rm bowtie2-2.5.3-linux-x86_64.zip

# Add bowtie2 to PATH
ENV PATH="/opt/bowtie2:$PATH"

RUN curl -L -o /usr/local/bin/VarScan.jar \
    https://github.com/dkoboldt/varscan/releases/download/v2.4.6/VarScan.v2.4.6.jar

RUN echo '#!/bin/bash\njava -jar /usr/local/bin/VarScan.jar "$@"' > /usr/local/bin/varscan \
    && chmod +x /usr/local/bin/varscan

RUN apt-get update && apt-get install -y tabix

WORKDIR "/mnt"