######################################
# target
######################################
TARGET = gd32f303cct6


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization for size
OPT = -Os


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
######################################
# C sources
C_SOURCES =  \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_bkp.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_crc.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_pmu.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_spi.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_misc.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_can.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_enet.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_fwdgt.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_fmc.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_dma.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_sdio.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_dbg.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_timer.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_wwdgt.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_adc.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_gpio.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_rtc.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_usart.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_exmc.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_rcu.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_exti.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_i2c.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_dac.c \
Firmware/GD32F30x_standard_peripheral/Source/gd32f30x_ctc.c \
Firmware/CMSIS/GD/GD32F30x/Source/system_gd32f30x.c \
User/systick.c \
User/gd32f30x_it.c \
User/main.c

# ASM sources
ASM_SOURCES = Firmware/CMSIS/GD/GD32F30x/Source/GCC/startup_gd32f30x_hd.S


#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
# NONE for Cortex-M0/M0+/M3

# float-abi


# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DUSE_STDPERIPH_DRIVER \
-DGD32F30X_HD


# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-IFirmware/CMSIS \
-IFirmware/CMSIS/GD/GD32F30x/Include \
-IFirmware/GD32F30x_standard_peripheral/Include \
-IUser

# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = Firmware/Ld/Link.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -u_printf_float -specs=nosys.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.S Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

#######################################
# program
#######################################
program_openocd:
	openocd -f /usr/share/openocd/scripts/interface/cmsis-dap.cfg -f /usr/share/openocd/scripts/target/stm32f4x.cfg -c "program build/$(TARGET).elf verify reset exit"

program_pyocd:
	pyocd erase -c -t gd32f450zg --config pyocd.yaml
	pyocd load build/$(TARGET).hex -t gd32f450zg --config pyocd.yaml

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
