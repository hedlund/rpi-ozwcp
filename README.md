# rpi-ozwcp

A Docker image of OpenZWave Control Panel for running on the Raspberry Pi.

You need to map your Z-wave device into the Docker container, and most likely also mount
a config file as a volume:

	docker run -d -p 8090:8090 \
    	--device=/dev/ttyACM0:/dev/zwave:rwm \
    	-v $PWD/zwcfg_0xXXXXXXXX.xml:/install/open-zwave-control-panel/zwcfg_0xXXXXXXXX.xml \
    	hedlund/rpi-ozwcp

Here I'm mapping `/dev/ttyACM0` as my Z-wave device, and then I can simply specify `/dev/zwave`
in the control panel when initiating it.

`zwcfg_0xXXXXXXXX.xml` should also be replaced with the proper ID of your device. An easy way
to get a file is to run the application once without any volume mounting and then grab the file
it creates.
