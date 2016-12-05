FROM resin/rpi-raspbian
MAINTAINER Henrik Hedlund <henrik@hedlund.im>

ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Update and install python
RUN apt-get update -y && \
	apt-get install -y build-essential git wget libgnutls28-dev libgnutlsxx28

RUN mkdir /install && cd /install && \
	wget ftp://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.19.tar.gz && \
	tar zxvf libmicrohttpd-0.9.19.tar.gz && \
	mv libmicrohttpd-0.9.19 libmicrohttpd && \
	cd libmicrohttpd && \
	./configure && \
	make && \
	make install

RUN apt-get install -y libudev-dev && \
	cd /install && \
	git clone https://github.com/OpenZWave/open-zwave.git && \
	cd open-zwave && \
	make

RUN cd /install && \
	git clone https://github.com/OpenZWave/open-zwave-control-panel.git && \
	cd open-zwave-control-panel && \
	sed -i 's|LIBMICROHTTPD := .*|LIBMICROHTTPD := /usr/local/lib/libmicrohttpd.a|g' Makefile && \
	sed -i 's|#LIBUSB := -ludev|LIBUSB := -ludev|g' Makefile && \
	sed -i 's|#LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) -lresolv|LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) -lresolv|g' Makefile && \
	sed -i 's|LIBUSB := -framework IOKit -framework CoreFoundation|#LIBUSB := -framework IOKit -framework CoreFoundation|g' Makefile && \
	sed -i 's|LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) \$(ARCH) -lresolv|#LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) \$(ARCH) -lresolv|g' Makefile && \
	make && \
	ln -sd ../open-zwave/config

EXPOSE 8090

WORKDIR /install/open-zwave-control-panel

ENTRYPOINT ["ozwcp"]
