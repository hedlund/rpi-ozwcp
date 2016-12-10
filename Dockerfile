FROM hedlund/rpi-raspbian
MAINTAINER Henrik Hedlund <henrik@hedlund.im>

# Install a few dependencies
RUN apt-get update && apt-get install -y libgnutls28-dev libgnutlsxx28

# Install libmicrohttpd
RUN mkdir /install && \
	wget -qO- ftp://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.19.tar.gz | tar xvz -C /install && \
	cd /install/libmicrohttpd-0.9.19 && \
	./configure && make && make install && \
	rm -rf /install/libmicrohttpd-0.9.19

# Install open-zwave
RUN git clone https://github.com/OpenZWave/open-zwave.git /install/open-zwave && \
	cd /install/open-zwave && make

# Install open-zwave-control-panel
RUN git clone https://github.com/OpenZWave/open-zwave-control-panel.git /install/open-zwave-control-panel && \
	cd /install/open-zwave-control-panel && \
	sed -i 's|LIBMICROHTTPD := .*|LIBMICROHTTPD := /usr/local/lib/libmicrohttpd.a|g' Makefile && \
	sed -i 's|#LIBUSB := -ludev|LIBUSB := -ludev|g' Makefile && \
	sed -i 's|#LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) -lresolv|LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) -lresolv|g' Makefile && \
	sed -i 's|LIBUSB := -framework IOKit -framework CoreFoundation|#LIBUSB := -framework IOKit -framework CoreFoundation|g' Makefile && \
	sed -i 's|LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) \$(ARCH) -lresolv|#LIBS := \$(LIBZWAVE) \$(GNUTLS) \$(LIBMICROHTTPD) -pthread \$(LIBUSB) \$(ARCH) -lresolv|g' Makefile && \
	make && ln -sd ../open-zwave/config

EXPOSE 8090

WORKDIR /install/open-zwave-control-panel

ENTRYPOINT ["./ozwcp"]
