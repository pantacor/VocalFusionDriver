LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

target_cross := $(TARGET_CROSS)
ifdef TARGET_LINUX_CROSS
target_cross := $(TARGET_LINUX_CROSS)
endif

ifndef TARGET_LINUX_ARCH
  TARGET_LINUX_ARCH := $(TARGET_ARCH)
endif

ifeq ("$(TARGET_LINUX_ARCH)","x64")
  LINUX_ARCH := x86_64
  LINUX_SRCARCH := x86
else ifeq ("$(TARGET_LINUX_ARCH)","aarch64")
  LINUX_ARCH := arm64
  LINUX_SRCARCH := arm64
else
  LINUX_ARCH := $(TARGET_LINUX_ARCH)
  LINUX_SRCARCH := $(TARGET_LINUX_ARCH)
endif

LOCAL_MODULE := vocalfusion_v5
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE).done

LOCAL_LIBRARIES := linux

VOCAL_V5_SRC_DIR := $(LOCAL_PATH)/driver
VOCAL_V5_BUILD_DIR := $(call local-get-build-dir)

KERNELDIR := $(TARGET_OUT)/build/linux
KERNELVER := $$(cat $(TARGET_OUT)/build/linux/include/config/kernel.release)

VOCAL_V5_MAKE_ARGS := \
	ARCH=$(LINUX_SRCARCH) \
	CONFIG_PREFIX="$(TARGET_OUT_STAGING)" \
	CROSS_COMPILE="$(target_cross)" \
	CROSS="$(target_cross)" \
	KERNELDIR="$(KERNELDIR)" \
	KERNELRELEASE="$(KERNELVER)" \
	MODBASE="$(TARGET_OUT_STAGING)" \
	PREFIX="$(TARGET_OUT_STAGING)" \
	V=$(V) \
	$(NULL)

$(VOCAL_V5_BUILD_DIR)/$(LOCAL_MODULE_FILENAME):
	@echo "Building for $(KERNELVER)"
	cp -f $(VOCAL_V5_SRC_DIR)/vocalfusion-soundcard.c $(VOCAL_V5_BUILD_DIR)/vocalfusion-soundcard.c
	cp -f $(VOCAL_V5_SRC_DIR)/Makefile $(VOCAL_V5_BUILD_DIR)/Makefile
	cd $(VOCAL_V5_BUILD_DIR) && $(VOCAL_V5_MAKE_ARGS) $(MAKE) -C $(KERNELDIR) M=$(VOCAL_V5_BUILD_DIR) modules CFLAGS_MODULE="-DRPI_4B -DI2S_MASTER"
	cd $(VOCAL_V5_BUILD_DIR) && $(VOCAL_V5_MAKE_ARGS) $(MAKE) -C $(KERNELDIR) M=$(VOCAL_V5_BUILD_DIR) INSTALL_MOD_PATH=$(TARGET_OUT_STAGING) modules_install

include $(BUILD_CUSTOM)