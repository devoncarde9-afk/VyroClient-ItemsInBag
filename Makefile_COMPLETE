TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VyroClient_ItemsInBag

VyroClient_ItemsInBag_FILES = VyroClient_ItemsInBag_Addon.x
VyroClient_ItemsInBag_CFLAGS = -fobjc-arc
VyroClient_ItemsInBag_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
