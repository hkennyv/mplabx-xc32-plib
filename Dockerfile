FROM ubuntu:bionic

# AWS APT mirrors
RUN sed -i 's+http://security.ubuntu.com/+http://archive.ubuntu.com/+g' /etc/apt/sources.list \
 && sed -i 's+http://archive.ubuntu.com/+http://us-east-1.ec2.archive.ubuntu.com/+g' /etc/apt/sources.list \
 && apt update \
 && rm -rf /var/lib/apt/lists/*

# Install git and ssh
RUN apt update \
 && apt install -y git ssh-client \
 && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN dpkg --add-architecture i386 \
 && apt update \
 && apt install -y --no-install-recommends curl libc6:i386 \
        libx11-6:i386 libxext6:i386 libstdc++6:i386 libexpat1:i386 \
        libxext6 libxrender1 libxtst6 libgtk2.0-0 make \
 && rm -rf /var/lib/apt/lists/*

# Install python modules
# RUN apt update \
#  && apt install -y python-pip python-setuptools \
#  && rm -rf /var/lib/apt/lists/* \
#  && pip install --upgrade pip
# RUN pip install glob2

# Add useful script for cleaning up after Microchip installs
# ADD microchip-remove-unused /usr/bin

# Download and install XC32 compiler
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc32.run "http://ww1.microchip.com/downloads/en/DeviceDoc/xc32-v2.41-full-install-linux-installer.run" \
 && chmod a+x /tmp/xc32.run \
 && /tmp/xc32.run --mode unattended --unattendedmodeui none \
    --netservername localhost --LicenseType FreeMode \
 && rm /tmp/xc32.run
 # && microchip-remove-unused
ENV PATH /opt/microchip/xc32/`ls /opt/microchip/xc32/ | awk '{print $1}'`/bin:$PATH

# Download and install XC16 compiler
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc16.run "http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.50-full-install-linux64-installer.run" \
 && chmod a+x /tmp/xc16.run \
 && /tmp/xc16.run --mode unattended --unattendedmodeui none \
    --netservername localhost --LicenseType FreeMode \
 && rm /tmp/xc16.run
 # && microchip-remove-unused
ENV PATH /opt/microchip/xc16/`ls /opt/microchip/xc16/ | awk '{print $1}'`/bin:$PATH

# Download and install MPLAB X IDE
# Use url: http://www.microchip.com/mplabx-ide-linux-installer to get the latest version
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/mplabx-installer.tar "http://ww1.microchip.com/downloads/en/DeviceDoc/MPLABX-v5.40-linux-installer.tar" \
 && tar xf /tmp/mplabx-installer.tar && rm /tmp/mplabx-installer.tar \
 && USER=root ./*-installer.sh --nox11 \
    -- --unattendedmodeui none --mode unattended \
 && rm ./*-installer.sh
 # && microchip-remove-unused

# Download and install PIC32 Legacy libraries
#RUN curl -fSL -A "Mozilla/4.0" -o /tmp/pic32-legacy-installer.tar "ww1.microchip.com/downloads/en/softwarelibrary/pic32%20peripheral%20library/pic32%20legacy%20peripheral%20libraries%20linux%20(2).tar" \
# && tar xf /tmp/pic32-legacy-installer.tar && rm /tmp/pic32-legacy-installer.tar \
# && ./PIC32\ Legacy\ Peripheral\ Libraries.run -- --unattendedmodeui none --mode unattended --prefix /opt/microchip/xc32/`ls /opt/microchip/xc32/ | awk '{print $1}'`/ \
# && rm ./PIC32\ Legacy\ Peripheral\ Libraries.run \
# && microchip-remove-unused

# Add MPLABX build scripts
# ADD mplabxBuildAll.py /usr/bin
# ADD mplabxBuildProject.py /usr/bin
# ADD mplabx-make-warnings-into-errors /usr/bin
# RUN ln -s /usr/bin/mplabxBuildAll.py /usr/bin/mplabx-build-all
# RUN ln -s /usr/bin/mplabxBuildProject.py /usr/bin/mplabx-build-project
# RUN rm /usr/bin/microchip-remove-unused

# add xc32 bins to path
ENV PATH="/opt/microchip/xc32/v2.41/bin:${PATH}"

# add mplab bins to path
ENV PATH="/opt/microchip/mplabx/v5.40/mplab_platform/bin:${PATH}"
