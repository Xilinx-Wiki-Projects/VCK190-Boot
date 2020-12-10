<img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="50%"/>

# Versal Example Design: Post BootROM State

## **Design Summary**
This Versal example design is intended to illustrate the post bootROM state (pre-PLM) of the device on different boot modes, just to verify the registers modified by Versal ROM code. The idea is to replicate for Versal the information provided on Table 6-22 and Table 6-11 of UG585 for zynq-7000 and Table 37-7 of UG1085 for Zynq UltraScale+ MPSoC/RFSoC.

---

## **Required Hardware and Tools**
- 2020.2 Vivado and Vitis
- VCK190 Rev A.3 (ES1)
- Boot Modules:
  - X-EBM-01 (Dual Parallel QSPI) Rev_A01

---

## **Build Instructions**

### **Vitis:**
Be sure to source `settings.sh` for Vitis.
Run the vitis.tcl script from the `Scripts` directory.
From the command line run the following:

```
xsct ./Scripts/vitis.tcl
```

The Vitis workspace will be created in `Software/Vitis/workspace` with the VCK190_platform and the customized PLM code.
The PLM is customized by adding a `while(1);` loop at the beginng of main() to halt the PLM execution so bootROM post configuration is NOT altered.

Additionally the boot image containing solely the custom PLM will be generated and the BOOT.bin file placed within the `Software/Vitis/bootimage` folder.

Program/copy the boot image into the boot device:
- **SD:** Copy the BOOT.bin file into the SD card
- **QSPI:** Use program_flash to program the flash device with the previously generated boot image.
```
program_flash -f Software/Vitis/bootimage/BOOT.bin -pdi Software/Vitis/workspace/vck190_platform/hw/vck190.pdi -flash_type qspi-x8-dual_parallel -url <hw_server URL>
```

---

## **Validation**

The example design is validated using a script that read relevant registers. The script takes as reference the boot mode and the URL of the hw_server used to connect to the device and dumps the register values. The script assumes the board is configured in JTAG boot mode and the boot image has been already programed/copied into the boot device.
Run the script from the `vck190_post_boot` directory.
```
xsct Scripts/postbootrom.tcl -bootmode qspi32 -url <hw_server URL>
```

Here an example of the script output:
```
Versal PostBootROM Register Status
HW Server URL:  XXXXXXXXXX
attempting to launch symbol_server
Boot mode: qspi32
Microblaze PPU, pc: f020076c


*** PLL Clock Registers
NOCPLL_CTRL is 0x00024809
PMCPLL_CTRL is 0x00024800
APLL_CTRL is 0x00024809
RPLL_CTRL is 0x00024809
CPLL_CTRL is 0x00024800

*** Processor Clock Registers
ACPU_CTRL is 0x02000200
CPU_R5_CTRL is 0x0E000300

*** Peripheral Clock Registers
SDIO1_REF_CTRL is 0x01000600
QSPI_REF_CTRL is 0x01000B00
CFU_REF_CTRL is 0x02000300
I2C_REF_CTRL is 0x00000C00
NPI_REF_CTRL is 0x00000400
SDDLL_REF_CTRL is 0x00000100
SDIO0_REF_CTRL is 0x01000600
OSPI_REF_CTRL is 0x01000400

*** MIO Registers
0xF1060000: 0x00000006
0xF1060004: 0x00000006
0xF1060008: 0x00000006
0xF106000C: 0x00000006
0xF1060010: 0x00000006
0xF1060014: 0x00000006

```
---

## **Results**
### Clocks

#### PLL

| Register Name | Base Address | Reset Value   | JTAG  | 32 | SD1_LS |
|---|---|---|---|---|---|
| PMCPLL_CTRL | 0xF1260040 | 0x00024809 | **0x00024800**  | **0x00024800**  | **0x00024800** |
| NOCPLL_CTRL | 0xF1260050 | 0x00024809 |  - |  - | -  |
| APLL_CTRL   | 0xFD1A0040 | 0x00024809 |  - | -  | -  |
| RPLL_CTRL   | 0xFF5E0040 | 0x00024809 |  - | -  | -  |
| CPLL_CTRL   | 0xF1260040 | 0x00024809 | **0x00024800** | **0x00024800**  | **0x00024800** |

#### Processors

| Register Name | Base Address | Reset Value   | JTAG  | 32 | SD1_LS |
|---|---|---|---|---|---|
| ACPU_CTRL   | 0XFD1A010C | 0X02000200 | -  | -  | - |
| CPU_R5_CTRL | 0XFF5E010C | 0x0E000300 |  - |  - | -  |

#### Peripherals

| Register Name | Base Address | Reset Value   | JTAG  | 32 | SD1_LS |
|---|---|---|---|---|---|
| QSPI_REF_CTRL  | 0XF1260118 | 0X01000400 | - | **0x1000B00**  | - |
| OSPI_REF_CTRL  | 0xF1260120 | 0X01000400 | - | - | - |
| SDIO0_REF_CTRL | 0xF1260124 | 0x01000600 | - | - | - |
| SDIO1_REF_CTRL | 0XF1260128 | 0x01000600 | - | - | **0x01001200** |
| SD_DLL_REF_CTRL| 0XF1260160 | 0X00000100 | - | - | - |
| I2C_REF_CTRL   | 0xF1260130 | 0x00000C00 | - | - | - |
| CFU_REF_CTRL   | 0xF1260108 | 0x02000300 | - | - | - |
| NPI_REF_CTRL   | 0xF1260114 | 0x00000400 | - | - | - |

### Multiplexed IOs

#### QSPI32 with x4 single configuration
| Base Address | MIO Pin | Register Value  | I/O signal |
|---|---|---|---|
|0xF1060000 | MIO_PIN_0 | **0x6** | qspi_sclk_out |
|0xF1060004 | MIO_PIN_1 | **0x6** | qspi_mo1 |
|0xF1060008 | MIO_PIN_2 | **0x6** | qspi_mo2 |
|0xF106000C | MIO_PIN_3 | **0x6** | qspi_mo3 |
|0xF1060010 | MIO_PIN_4 | **0x6** | qspi_mi0 |
|0xF1060014 | MIO_PIN_5 | **0x6** | qspi_n_ss_out |
|0xF1060018 | MIO_PIN_6 | 0x0 | sysmon_i2c_smbalert_input |

`BootROM does not use qspi_clk_for_lpbk signal so the MIO Pin 6 remains in the default state as an input signal`

#### QSPI32 with x8 dual parallel configuration
| Base Address | MIO Pin | Register Value  | I/O signal |
|---|---|---|---|
|0xF1060000 | MIO_PIN_0 | **0x6** | qspi_sclk_out |
|0xF1060004 | MIO_PIN_1 | **0x6** | qspi_mo1 |
|0xF1060008 | MIO_PIN_2 | **0x6** | qspi_mo2 |
|0xF106000C | MIO_PIN_3 | **0x6** | qspi_mo3 |
|0xF1060010 | MIO_PIN_4 | **0x6** | qspi_mi0 |
|0xF1060014 | MIO_PIN_5 | **0x6** | qspi_n_ss_out |
|0xF106001C | MIO_PIN_7 | **0x6** | qspi_n_ss_out_upper |
|0xF1060020 | MIO_PIN_8 | **0x6** | qspi_upper[0] |
|0xF1060024 | MIO_PIN_9 | **0x6** | qspi_upper[1] |
|0xF1060028 | MIO_PIN_10 | **0x6** | qspi_upper[2] |
|0xF106002C | MIO_PIN_11 | **0x6** | qspi_upper[3] |
|0xF1060030 | MIO_PIN_12 | **0x6** | qspi_sclk_out_upper |

`BootROM does not use qspi_clk_for_lpbk signal so the MIO Pin 6 remains in the default state as an input signal`

#### SD1_LS (3.0)
| Base Address | MIO Pin | Register Value  | I/O signal |
|---|---|---|---|
|0xF1060068 | MIO_PIN_26 | **0x2** | sdio1_clk_out |
|0xF106006C | MIO_PIN_27 | **0x2** | sd1_data[7[]] |
|0xF1060070 | MIO_PIN_28 | 0x0 | sysmon_i2c_smbalert_input |
|0xF1060074 | MIO_PIN_29 | **0x2** | sd1_cmd |
|0xF1060078 | MIO_PIN_30 | **0x2** | sd1_data[0] |
|0xF106007C | MIO_PIN_31 | **0x2** | sd1_data[1] |
|0xF1060080 | MIO_PIN_32 | **0x2** | sd1_data[2] |
|0xF1060084 | MIO_PIN_33 | **0x2** | sd1_data[3] |
|0xF1060088 | MIO_PIN_34 | **0x2** | sd1_data[4] |
|0xF106008C | MIO_PIN_35 | **0x2** | sd1_data[5] |
|0xF1060090 | MIO_PIN_36 | **0x2** | sd1_data[6] |
|0xF10600C8 | MIO_PIN_50 | 0x0 | sysmon_i2c_sda_input |
|0xF10600CC | MIO_PIN_51 | **0x2** | sdio1_bus_pow |

`BootROM does not use sdio1_cd_n and sdio1_wp signals so the MIO Pin 28 and 50 remains in the default state as an input signal`

© Copyright [2020] Xilinx, Inc. All rights reserved.
