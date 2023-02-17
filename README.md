# gd32f30x firmware library with gcc and makefile support

This is pre-converted gd32f30x firmware library with gcc and makefile support from GigaDevice official 'GD32F30x_Firmware_Library_V2.1.5.rar'.

For more information about how to use this library, refer to [this tutorial](https://github.com/cjacker/opensource-toolchain-stm32).

This firmware library support gd32f303/305/307 parts from GigaDevice:

The default part is set to 'gd32f303cct6' for [WeAct GD32 Bluepill Plus](https://github.com/WeActStudio/BluePill-Plus).

The default 'User' codes is blinking the LED connect to PB2.

To build the project, type `make`.


# to support other parts
To support other GD32F30x parts, you need:

- change 'Firmware/Ld/Link.ld' to set FLASH and RAM size according to your MCU.
- choose correct startup asm file and change the 'ASM_SOURCES' in 'Makefile'
  + Firmware/CMSIS/GD/GD32F30x/Source/GCC/startup_gd32f30x_hd.S: for Flash size range from 256K to 512K
  + Firmware/CMSIS/GD/GD32F30x/Source/GCC/startup_gd32f30x_xd.S: for Flash size > 512K
  + Firmware/CMSIS/GD/GD32F30x/Source/GCC/startup_gd32f30x_cl.S: for GD32F305 and 307
- change `-DGD32F30X_HD` C_DEFS in 'Makefile' to `HD`, `XD` or `CL` according to your MCU.
- change the 'TARGET' in 'Makefile'

