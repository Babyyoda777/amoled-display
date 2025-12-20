obj-m += panel-pibrick.o
DTBO_NAME := amoled-display
MODULE_NAME := panel-pibrick.ko
CONFIG_TXT := /boot/firmware/config.txt
OVERLAY_DIR := /boot/firmware/overlays
MODULE_INSTALL_DIR := /lib/modules/$(shell uname -r)/kernel/drivers/gpu/drm/panel

all: modules dtbo

modules:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

dtbo:
	dtc -@ -I dts -O dtb -o $(DTBO_NAME).dtbo $(DTBO_NAME).dts

clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
	rm -rf *.dtbo

install: remove all
	# Install Kernel Module
	sudo install -m 644 -D $(MODULE_NAME) $(MODULE_INSTALL_DIR)/$(MODULE_NAME)
	sudo depmod -a
	
	# Install Device Tree Overlay
	sudo install -m 644 -D $(DTBO_NAME).dtbo $(OVERLAY_DIR)/$(DTBO_NAME).dtbo
	
	# Enable Overlay in Config
	@if ! grep -q "dtoverlay=$(DTBO_NAME)" $(CONFIG_TXT); then \
		echo "Adding dtoverlay to config.txt..."; \
		echo "dtoverlay=$(DTBO_NAME)" | sudo tee -a $(CONFIG_TXT); \
	fi
	
	echo "Installation complete. Please reboot."

remove:
	# Remove Kernel Module
	sudo rm -f $(MODULE_INSTALL_DIR)/$(MODULE_NAME)
	sudo depmod -a
	
	# Remove Device Tree Overlay
	sudo rm -f $(OVERLAY_DIR)/$(DTBO_NAME).dtbo
	
	# Disable Overlay in Config
	sudo sed -i "/dtoverlay=$(DTBO_NAME)/d" $(CONFIG_TXT)
	
	echo "Driver removed."
