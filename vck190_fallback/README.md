<img src="https://www.xilinx.com/content/dam/xilinx/imgs/press/media-kits/corporate/xilinx-logo.png" width="50%"/>

# Versal Example Design: Fallback & Multiboot 

## **Design Summary**

Fallback boot allows Versal ACAP to automatically boot a different PDI than the initial PDI on the same primary boot device if the first PDI fails to boot.

MultiBoot allows the software developer to specify a different PDI than the initial PDI on the same primary boot device to use for the next Versal ACAP boot process.

### **Fallback Boot process**

Fallback boot process (starting from the initial boot after POR):

The BootROM executable accesses the PDI at the location specified when PMC_MULTI_BOOT is 0 (the POR value). The BootROM executable performs integrity and security checks on the boot header (valid ID,
checksum), and the associated PLM, ensures that the PDI is not corrupted, decrypts the PDI, and checks that authentication is successful.

If the **integrity** and **security** checks fail, then the fallback boot is used to try to boot Versal ACAP from an alternate PDI on the same primary boot device.

To begin the **fallback** boot, the BootROM executable increments PMC_MULTI_BOOT within search offset limit and executes a system-level reset (SRST), which then uses the PMC_MULTI_BOOT register to read the PDI from the newly specified location within the primary boot device.

From this point, there are two paths:


• **Success**: If the BootROM executable finds a boot header at the new location, BootROM performs boot integrity and security checks on the boot header/PLM. If the integrity and security checks pass, then boot continues.

• **Failure**: In this case, either the BootROM executable does not find a boot header at the new location, or the boot header/PLM integrity and security checks fail. The BootROM executable again increments PMC_MULTI_BOOT, issues an SRST, and continues searching, while incrementing PMC_MULTI_BOOT as needed until either a valid boot header/PLM is found, or the search limit is reached.

**MultiBoot (after a system reset):**


•After the initial boot, either the PLM or an application changes PMC_MULTI_BOOT and then issues a system reset, which does not change PMC_MULTI_BOOT. The BootROM executable accesses the PDI at the new location specified by PMC_MULTI_BOOT.   

## **PMC_MULTIBOOT register**

Inside the PMC, there is a MultiBoot register (PMC_MULTI_BOOT). After a system-level reset (SRST), the BootROM executable uses PMC_MULTI_BOOT to specify the PDI location in
the boot device. PMC_MULTI_BOOT is a number. The type of boot device determines whether PMC_MULTI_BOOT is used to specify the alternative PDI location as an address or a file name. 

A key difference between fallback boot and MultiBoot is that POR resets PMC_MULTI_BOOT to 0. A system-level (SRST) reset does not change PMC_MULTI_BOOT.

## **Boot Device Choices for fallback boot and Multiboot**

~~~

eMMC (4.51) ---------------------------------------------search offset limit **8191 FAT files
Qctal SPI single or dual stacked-------------------------search offset limit **8GB
Quad SPI24 Single or dual stacked------------------------search offset limit **128MB 
Quad SPI24 dual-parallel---------------------------------search offset limit **256MB
Quad SPI32 Single or dual stacked------------------------search offset limit **4GB
Quad SPI32 dual-parallel---------------------------------search offset limit **8GB
SD0 (1.0)------------------------------------------------search offset limit **8191 FAT files
SD1 (2.0)------------------------------------------------search offset limit **8191 FAT files
SD1 (3.0)------------------------------------------------search offset limit **8191 FAT files

~~~

## **Required Hardware and Tools**

2020.2 Vivado and Vitis

VCK190 Rev A.3 (ES1)

Boot Modules:
  - X-EBM-01 (Dual Parallel QSPI) Rev_A01
  - SD Card

---

## **Project is NOT**

A full tutorial to meet the all the usecases to load the working image in production environment.

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

### **Vitis**:

Following instruction on UG1305 "Versal ACAP Embedded Design Tutorial", import the vck190_wrapper.xsa from Vivado into Vitis, choose the Sofware folder as workspace and "Create application Project" for "Hello World" (for A72-0 linked to DDR) whithin the same System project called vck190_system.


#### **Generate the Boot Image (BIN) File**:

BootROM executable supports fallback boot and MultiBoot on Octal-SPI and Quad-SPI boot devices. First, one or more PDI files are created. Then, the flash programmer specifies that one PDI will be stored at offset 0x0, and any remaining PDI at a specified offset, which is 64 KB aligned. The PDI is location independent, so the same PDI can be used at multiple locations.

image.bif

```
all:
{
[bootimage] versal_fallback_wrapper.pdi
[destination_cpu=a72-0] boot0000.elf

}
```
Generate a Boot Image (BIN) using the following bootgen command:
```
exec bootgen -image image.bif -arch versal -o boot0000.bin 
```


#### **Program a QSPI Boot Image (BIN)**:

For Octal SPI and Quad SPI, PMC_MULTI_BOOT is used as an index into the flash device. PMC_MULTI_BOOT is multiplied by 32 KB to calculate the flash offset.

Run the below program_flash command and set the required offset values. 

```
xsct% program_flash -f boot0000.bin -pdi versal_fallback_wrapper.pdi -offset 0x0 -flash_type qspi-x8-dual_parallel
xsct% program_flash -f boot0001.bin -pdi versal_fallback_wrapper.pdi -offset 0x0020000 -flash_type qspi-x8-dual_parallel
xsct% program_flash -f boot0002.bin -pdi versal_fallback_wrapper.pdi -offset 0x0040000 -flash_type qspi-x8-dual_parallel
```


#### **Load the SD card with the generated Boot Image (BIN)**:

The SD card or eMMC flash must be partitioned so that the first partition is a FAT 16/32 file system. Bootgen is used to create PDI files with the names: boot.bin, boot0001.bin, boot0002.bin, etc.
Except for the PMC_MULTI_BOOT value ‘0,’ the PMC_MULTI_BOOT value is concatenated with first the string boot, then PMC_MULTI_BOOT, then .bin to create the specified PDI file name. 

```
For example, if PMC_MULTI_BOOT= 2, then the PDI file name is boot0002.bin. 
```

For command-line users, the PDI file names are specified on the Bootgen command line. The PDI files are then
copied to the FAT16/32 file system on the boot device. The search limit specified for the device corresponds to the maximum number in the file name, for example, boot8190.bin.

Below shows set of 3 images in SD card for multiboot. 
```
boot.bin
boot0001.bin
boot0002.bin
etc...

```



## **Running the Design**

#### **NOTE**:

Please ignore the following error message:-
```
 "ERROR: PlHouseClean: Hard block scan clear / MBIST FAILED"
```


1. QSPI Boot

Program the QSPI with different images programmed at different offset locations. On power up device will boot from the first good image. Multiboot register can be read to find the booted image details. 

Note: For QSPI, after the initial (POR) boot PMC_Muliboot value is 00000000. 

For reading the multiboot register, use the below command:- 

```
mrd 0xF1110004 

```

You can try to load the device from offset value by setting the PMC_multiboot register and sending the system reset.

```
#Set the 0xF1110004 to another boot image. In this case, I will set it to 2. 

xsct% mwr 0xF1110004 0x2

#send the system reset, this will not reset the PMC_multiboot value. 

rst -sys 

```

For fallback, SYNC word is corrupted in the boot0000.bin image. 

~~~
Original: 665599aa
Corrupted: 6655aaaa

~~~~

**Note: Test results for fallback & multiboot have been captured in software/Vitis/Bootimage/QSPI/Sample_Results directory. **


2. SD card Boot

Load the SD card with multiple images with the file name as boot.bin,boot0001.bin,boot0002.bin etc. For SD card file name is used as multiboot register instead of offset. 
On power up device will boot from the first good image. Multiboot register can be read to find the booted image details. 

Note: For SD card, after the initial (POR) boot PMC_Muliboot value is F0000000. 

For reading the multiboot register, use the below command:- 

```
mrd 0xF1110004 

```

You can try to load the device from offset value by setting the PMC_multiboot register and sending the system reset.

```
#Set the 0xF1110004 to another boot image. In this case, I will set it to 2. 

xsct% mwr 0xF1110004 0x2

#send the system reset, this will not reset the PMC_multiboot value. 

rst -sys 

```
For fallback, SYNC word is corrupted in the boot0000.bin image. 

~~~
Original: 665599aa

Corrupted: 6655aaaa

~~~~

**Note: Test results for fallback & multiboot have been captured in software/Vitis/Bootimage/SD/Sample_Results directory. **

---

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
[1267.471346]+++++++Loading Image No: 0x7, Name: boot000.elf, Id: 0x1C000000
[1274.336540]+++++++Loading Prtn No: 0xB
[1279.157828] 1.112896 ms for PrtnNum: 11, Size: 163920 Bytes
[1283.563756]***********Boot PDI Load: Done*************
[1288.604543]28.515481 ms: ROM Time
[1291.820087]Total PLM Boot Time
I am the first partition sitting in Boot0000.bin
Hello Everyone
```


## © Copyright [2020] Xilinx, Inc. All rights reserved.
