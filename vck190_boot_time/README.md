<img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="50%"/>

# Versal Example Design: Boot Time 

## **Design Summary**

The goal is to be able to build a VCK190 design (QSPI dual paralell) to reproduce the boot times outlined in the boot time estimator spreadsheet. What optimizations can provide the best Boot Time improvement for boot time critical designs?

---

## **Required Hardware and Tools**

2020.1 Vivado and Vitis

VCK190 Rev A.3 (ES1)

Boot Modules:
  - X-EBM-01 (Dual Parallel QSPI) Rev_A01

---

## **Project is NOT**

A full tutorial to meet boot time requirements for very specific designs.

---

## **Block Diagram**

![Block Diagram](/images/block.PNG)

---

## **Build Instructions**

### **Vivado:**

Enter the `Scripts` directory. From the command line run the following:

`vivado -source project_top.tcl`

The Vivado project will be built in the `Hardware` directory.

Once the project is created, click on "Generate Device Image".

Wait until "Device Image Generation successfully completed" then "Open Implemented Design".
Exporting the XSA to the Software folder with the following TCL command:
```
write_hw_platform -fixed -include_bit -force -file ../Software/vck190_wrapper.xsa
```

#### **NOTE**:

In order to better estimate the bandwidth while loading the CFI, I remove the compression using the following constraint:
```
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
```
Doing so I got a ~85.9 MB PDI from Vivado.

### **Vitis**:

Following instruction on UG1305 "Versal ACAP Embedded Design Tutorial", import the vck190_wrapper.xsa from Vivado into Vitis, choose the Sofware folder as workspace and "Create pplication Project" for PLM, PSMFW and "Hello World" (for A72-0 linked to DDR) whithin the same System project called vck190_system.

#### **PLM MODIFICATION #1**:
In xloader_qspi.c (Xilloader), change the QSPI prescaler to 2 (default was 8):
```
/*
* Set the pre-scaler for QSPI clock
*/
Status = XQspiPsu_SetClkPrescaler(&QspiPsuInstance, XQSPIPSU_CLK_PRESCALE_2);
```

#### **PLM MODIFICATION #2**:
In xplmi_config.h (Xilplmi), define the following macros:
```
#define PLM_DEBUG
#define PLM_PRINT_PERF
#define PLM_PRINT_PERF_PL
```
in order to get the time break-down of the PL components.
```
[534.596184]PL supply status good
[574.426137]PL POR B status good
[574.550687]PL House Clean completed
```

#### **Generate a Boot Image (PDI)**:
Generate a Boot Image (PDI) using the following bootgen command and the output.bif already present in the Software/bootimage folder:
```
bootgen -arch versal -image output.bif -o BOOT.PDI -w
```
output.bif:
```
/*vck190_qspi*/
the_ROM_image:
{
[bootimage] ../vck190_wrapper/hw/vck190_wrapper.pdi 
[bootloader] ../plm/Debug/plm.elf 
[destination_cpu=psm] ../psmfw/Debug/psmfw.elf 
[destination_cpu=a72-0, exception_level=el-3] ../hello_a72_0/Debug/hello_a72_0.elf
}
```

## **Estimate the boot times**

![Block Diagram](/images/time_estimator.PNG)

## **Running the Design and collect the boot times**

Due to the VCCAUX issue on ES1 the boot time at power up is VERY different from the power up at SRST. 
At POR there's an extra 10 seconds added before CFI can be loaded (waiting for the System Controller to boot).
The SRST is forced using the following script and still add ab extra 300ms in order to power VCCRAM up/down to avoid excess current draw.

```
tar -set -filter {name =~ "Versal *"}
# Enable ISO
mwr -force 0xf1120000 0xffbff
# Switch boot mode
mwr 0xf1260200 0x2100
mrd 0xf1260200
# Set MULTIBOOT address to 0
mwr -force 0xF1110004 0x0
# SYSMON_REF_CTRL is switched to NPI by user PDI so ensure its
# switched back
mwr -force 0xF1260138 0
mwr -force 0xF1260320 0x77
# Perform reset
tar -set -filter {name =~ "PMC"}
rst
```

The Log has been capture after the SRST script using the XSDB command "plm log" from target 1:

```
[307.152043]PLM Initialization Time
[307.213418]***********Boot PDI Load: Started***********
[307.280031]Loading PDI from QSPI32
[307.342031]Monolithic/Master Device
[307.415534]FlashID=0x20 0xBB 0x21
[307.748121]0.433865 ms: PDI initialization time
[307.824846]+++++++Loading Image No: 0x1, Name: lpd_data.cdo, Id: 0x1C000000
[307.914196]+++++++Loading Prtn No: 0x1
[308.416293]****************************************
[310.290309]Xilinx Versal Platform Loader and Manager
[315.182565]Release 2020.1 Jul 9 2020 - 14:41:38
[319.988000]Platform Version: v1.0 PMC: v1.0, PS: v1.0
[324.877868]STDOUT: PS UART
[327.410843]****************************************
[332.167415] 24.145350 ms for PrtnNum: 1, Size: 2224 Bytes
[337.412303]+++++++Loading Image No: 0x2, Name: psmfw.elf, Id: 0x1C000000
[343.928271]+++++++Loading Prtn No: 0x2
[348.75315] 0.529162 ms for PrtnNum: 2, Size: 48 Bytes
[352.405240]+++++++Loading Prtn No: 0x3
[356.540431] 0.517024 ms for PrtnNum: 3, Size: 75168 Bytes
[361.230712]+++++++Loading Prtn No: 0x4
[364.877912] 0.29900 ms for PrtnNum: 4, Size: 2608 Bytes
[369.881484]+++++++Loading Prtn No: 0x5
[373.545946] 0.48859 ms for PrtnNum: 5, Size: 5440 Bytes
[378.529003]+++++++Loading Prtn No: 0x6
[382.158503] 0.11834 ms for PrtnNum: 6, Size: 32 Bytes
[387.67178]+++++++Loading Image No: 0x3, Name: design_1_wr., Id: 0x1C000000
[393.734828]+++++++Loading Prtn No: 0x7
[534.596184]PL supply status good
[574.426137]PL POR B status good
[574.550687]PL House Clean completed
[1194.626887] 797.272771 ms for PrtnNum: 7, Size: 89412640 Bytes
[1197.579290]+++++++Loading Image No: 0x4, Name: design_1_wr., Id: 0x1C000000
[1204.443253]+++++++Loading Prtn No: 0x8
[1233.664868] 25.515396 ms for PrtnNum: 8, Size: 361200 Bytes
[1236.354634]+++++++Loading Image No: 0x5, Name: fpd_data.cdo, Id: 0x1C000000
[1243.220265]+++++++Loading Prtn No: 0x9
[1247.95090] 0.168318 ms for PrtnNum: 9, Size: 976 Bytes
[1252.65]+++++++Loading Image No: 0x6, Name: subsystem.cd, Id: 0x1C000000
[1258.516175]+++++++Loading Prtn No: 0xA
[1262.396559] 0.173987 ms for PrtnNum: 10, Size: 336 Bytes
[1267.471346]+++++++Loading Image No: 0x7, Name: hello_a72_0., Id: 0x1C000000
[1274.336540]+++++++Loading Prtn No: 0xB
[1279.157828] 1.112896 ms for PrtnNum: 11, Size: 163920 Bytes
[1283.563756]***********Boot PDI Load: Done*************
[1288.604543]28.515481 ms: ROM Time
[1291.820087]Total PLM Boot Time
Hello World
Successfully ran Hello World application
```

## **Verify the boot times**

#### **NOTE**:
On the calculation, need to remove the VCC_RAM delay from the power controller of ~300ms.
For now there are few numbers I don't understand. Need to investigate:
1. psmfw.elf and hello.elf bandwidth is lower than expected
2. cdo bandwidth is lower than expected

