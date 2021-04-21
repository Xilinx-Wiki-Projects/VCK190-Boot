# Copyright 2020 Xilinx Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvc1902-vsva2197-2MP-e-S-es1
   set_property BOARD_PART xilinx.com:vck190_es:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name vck190_sd1_es1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_noc:1.0\
xilinx.com:ip:versal_cips:2.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ch0_lpddr4_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c0 ]

  set ch1_lpddr4_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c0 ]

  set lpddr4_sma_clk1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $lpddr4_sma_clk1


  # Create ports

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 axi_noc_0 ]
  set_property -dict [ list \
   CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {ch0_lpddr4_c0} \
   CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {ch1_lpddr4_c0} \
   CONFIG.CONTROLLERTYPE {LPDDR4_SDRAM} \
   CONFIG.LOGO_FILE {data/noc_mc.png} \
   CONFIG.MC0_CONFIG_NUM {config26} \
   CONFIG.MC0_FLIPPED_PINOUT {true} \
   CONFIG.MC1_CONFIG_NUM {config26} \
   CONFIG.MC1_FLIPPED_PINOUT {true} \
   CONFIG.MC2_CONFIG_NUM {config26} \
   CONFIG.MC3_CONFIG_NUM {config26} \
   CONFIG.MC_ADDR_BIT2 {CA0} \
   CONFIG.MC_ADDR_BIT3 {CA1} \
   CONFIG.MC_ADDR_BIT4 {CA2} \
   CONFIG.MC_ADDR_BIT5 {CA3} \
   CONFIG.MC_ADDR_BIT6 {BA0} \
   CONFIG.MC_ADDR_BIT7 {BA1} \
   CONFIG.MC_ADDR_BIT8 {BA2} \
   CONFIG.MC_ADDR_BIT9 {CA4} \
   CONFIG.MC_ADDR_BIT10 {CA5} \
   CONFIG.MC_ADDR_BIT11 {CA6} \
   CONFIG.MC_ADDR_BIT12 {CA7} \
   CONFIG.MC_ADDR_BIT13 {CA8} \
   CONFIG.MC_ADDR_BIT14 {CA9} \
   CONFIG.MC_ADDR_BIT15 {RA0} \
   CONFIG.MC_ADDR_BIT16 {RA1} \
   CONFIG.MC_ADDR_BIT17 {RA2} \
   CONFIG.MC_ADDR_BIT18 {RA3} \
   CONFIG.MC_ADDR_BIT19 {RA4} \
   CONFIG.MC_ADDR_BIT20 {RA5} \
   CONFIG.MC_ADDR_BIT21 {RA6} \
   CONFIG.MC_ADDR_BIT22 {RA7} \
   CONFIG.MC_ADDR_BIT23 {RA8} \
   CONFIG.MC_ADDR_BIT24 {RA9} \
   CONFIG.MC_ADDR_BIT25 {RA10} \
   CONFIG.MC_ADDR_BIT26 {RA11} \
   CONFIG.MC_ADDR_BIT27 {RA12} \
   CONFIG.MC_ADDR_BIT28 {RA13} \
   CONFIG.MC_ADDR_BIT29 {RA14} \
   CONFIG.MC_ADDR_BIT30 {RA15} \
   CONFIG.MC_ADDR_BIT31 {CH_SEL} \
   CONFIG.MC_ADDR_BIT32 {NA} \
   CONFIG.MC_ADDR_WIDTH {6} \
   CONFIG.MC_BA_WIDTH {3} \
   CONFIG.MC_BG_WIDTH {0} \
   CONFIG.MC_BOARD_INTRF_EN {true} \
   CONFIG.MC_BURST_LENGTH {16} \
   CONFIG.MC_CASLATENCY {28} \
   CONFIG.MC_CASWRITELATENCY {14} \
   CONFIG.MC_CH0_LP4_CHA_ENABLE {true} \
   CONFIG.MC_CH0_LP4_CHB_ENABLE {true} \
   CONFIG.MC_CH1_LP4_CHA_ENABLE {true} \
   CONFIG.MC_CH1_LP4_CHB_ENABLE {true} \
   CONFIG.MC_CKE_WIDTH {0} \
   CONFIG.MC_CK_WIDTH {0} \
   CONFIG.MC_COMPONENT_DENSITY {16Gb} \
   CONFIG.MC_COMPONENT_WIDTH {x32} \
   CONFIG.MC_CONFIG_NUM {config26} \
   CONFIG.MC_DATAWIDTH {32} \
   CONFIG.MC_DM_WIDTH {4} \
   CONFIG.MC_DQS_WIDTH {4} \
   CONFIG.MC_DQ_WIDTH {32} \
   CONFIG.MC_ECC {false} \
   CONFIG.MC_ECC_SCRUB_PERIOD {0x003E80} \
   CONFIG.MC_ECC_SCRUB_SIZE {1} \
   CONFIG.MC_EN_BACKGROUND_SCRUBBING {true} \
   CONFIG.MC_EN_ECC_SCRUBBING {false} \
   CONFIG.MC_EN_INTR_RESP {TRUE} \
   CONFIG.MC_F1_CASLATENCY {28} \
   CONFIG.MC_F1_CASWRITELATENCY {14} \
   CONFIG.MC_F1_LPDDR4_MR1 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR2 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR3 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR11 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR13 {0x00C0} \
   CONFIG.MC_F1_LPDDR4_MR22 {0x0000} \
   CONFIG.MC_F1_TCCD_L {0} \
   CONFIG.MC_F1_TCCD_L_MIN {0} \
   CONFIG.MC_F1_TFAW {40000} \
   CONFIG.MC_F1_TFAWMIN {40000} \
   CONFIG.MC_F1_TMOD {0} \
   CONFIG.MC_F1_TMOD_MIN {0} \
   CONFIG.MC_F1_TMRD {14000} \
   CONFIG.MC_F1_TMRDMIN {14000} \
   CONFIG.MC_F1_TMRW {10000} \
   CONFIG.MC_F1_TMRWMIN {10000} \
   CONFIG.MC_F1_TRAS {42000} \
   CONFIG.MC_F1_TRASMIN {42000} \
   CONFIG.MC_F1_TRCD {18000} \
   CONFIG.MC_F1_TRCDMIN {18000} \
   CONFIG.MC_F1_TRPAB {21000} \
   CONFIG.MC_F1_TRPABMIN {21000} \
   CONFIG.MC_F1_TRPPB {18000} \
   CONFIG.MC_F1_TRPPBMIN {18000} \
   CONFIG.MC_F1_TRRD {10000} \
   CONFIG.MC_F1_TRRDMIN {10000} \
   CONFIG.MC_F1_TRRD_L {0} \
   CONFIG.MC_F1_TRRD_L_MIN {0} \
   CONFIG.MC_F1_TRRD_S {0} \
   CONFIG.MC_F1_TRRD_S_MIN {0} \
   CONFIG.MC_F1_TWR {18000} \
   CONFIG.MC_F1_TWRMIN {18000} \
   CONFIG.MC_F1_TWTR {10000} \
   CONFIG.MC_F1_TWTRMIN {10000} \
   CONFIG.MC_F1_TWTR_L {0} \
   CONFIG.MC_F1_TWTR_L_MIN {0} \
   CONFIG.MC_F1_TWTR_S {0} \
   CONFIG.MC_F1_TWTR_S_MIN {0} \
   CONFIG.MC_F1_TZQLAT {30000} \
   CONFIG.MC_F1_TZQLATMIN {30000} \
   CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {false} \
   CONFIG.MC_INPUTCLK0_PERIOD {5000} \
   CONFIG.MC_INPUT_FREQUENCY0 {200.000} \
   CONFIG.MC_IP_TIMEPERIOD0_FOR_OP {1071} \
   CONFIG.MC_LP4_CA_A_WIDTH {6} \
   CONFIG.MC_LP4_CA_B_WIDTH {6} \
   CONFIG.MC_LP4_CKE_A_WIDTH {1} \
   CONFIG.MC_LP4_CKE_B_WIDTH {1} \
   CONFIG.MC_LP4_CKT_A_WIDTH {1} \
   CONFIG.MC_LP4_CKT_B_WIDTH {1} \
   CONFIG.MC_LP4_CS_A_WIDTH {1} \
   CONFIG.MC_LP4_CS_B_WIDTH {1} \
   CONFIG.MC_LP4_DMI_A_WIDTH {2} \
   CONFIG.MC_LP4_DMI_B_WIDTH {2} \
   CONFIG.MC_LP4_DQS_A_WIDTH {2} \
   CONFIG.MC_LP4_DQS_B_WIDTH {2} \
   CONFIG.MC_LP4_DQ_A_WIDTH {16} \
   CONFIG.MC_LP4_DQ_B_WIDTH {16} \
   CONFIG.MC_LP4_RESETN_WIDTH {1} \
   CONFIG.MC_MEMORY_DENSITY {2GB} \
   CONFIG.MC_MEMORY_DEVICE_DENSITY {16Gb} \
   CONFIG.MC_MEMORY_SPEEDGRADE {LPDDR4-3200} \
   CONFIG.MC_MEMORY_TIMEPERIOD0 {625} \
   CONFIG.MC_MEMORY_TIMEPERIOD1 {625} \
   CONFIG.MC_MEM_DEVICE_WIDTH {x32} \
   CONFIG.MC_NO_CHANNELS {Dual} \
   CONFIG.MC_ODTLon {6} \
   CONFIG.MC_ODT_WIDTH {0} \
   CONFIG.MC_PER_RD_INTVL {0} \
   CONFIG.MC_PRE_DEF_ADDR_MAP_SEL {ROW_COLUMN_BANK} \
   CONFIG.MC_REFRESH_SPEED {1x} \
   CONFIG.MC_TCCD {8} \
   CONFIG.MC_TCCD_L {0} \
   CONFIG.MC_TCCD_L_MIN {0} \
   CONFIG.MC_TCKE {12} \
   CONFIG.MC_TCKEMIN {12} \
   CONFIG.MC_TDQS2DQ_MAX {800} \
   CONFIG.MC_TDQS2DQ_MIN {200} \
   CONFIG.MC_TDQSCK_MAX {3500} \
   CONFIG.MC_TFAW {40000} \
   CONFIG.MC_TFAWMIN {40000} \
   CONFIG.MC_TFAW_nCK {0} \
   CONFIG.MC_TMOD {0} \
   CONFIG.MC_TMOD_MIN {0} \
   CONFIG.MC_TMPRR {0} \
   CONFIG.MC_TMRD {14000} \
   CONFIG.MC_TMRDMIN {14000} \
   CONFIG.MC_TMRD_div4 {10} \
   CONFIG.MC_TMRD_nCK {23} \
   CONFIG.MC_TMRW {10000} \
   CONFIG.MC_TMRWMIN {10000} \
   CONFIG.MC_TMRW_div4 {10} \
   CONFIG.MC_TMRW_nCK {16} \
   CONFIG.MC_TODTon_MIN {3} \
   CONFIG.MC_TOSCO {40000} \
   CONFIG.MC_TOSCOMIN {40000} \
   CONFIG.MC_TOSCO_nCK {64} \
   CONFIG.MC_TPBR2PBR {90000} \
   CONFIG.MC_TPBR2PBRMIN {90000} \
   CONFIG.MC_TRAS {42000} \
   CONFIG.MC_TRASMIN {42000} \
   CONFIG.MC_TRAS_nCK {68} \
   CONFIG.MC_TRC {63000} \
   CONFIG.MC_TRCD {18000} \
   CONFIG.MC_TRCDMIN {18000} \
   CONFIG.MC_TRCD_nCK {29} \
   CONFIG.MC_TRCMIN {0} \
   CONFIG.MC_TREFI {3904000} \
   CONFIG.MC_TREFIPB {488000} \
   CONFIG.MC_TRFC {0} \
   CONFIG.MC_TRFCAB {280000} \
   CONFIG.MC_TRFCABMIN {280000} \
   CONFIG.MC_TRFCMIN {0} \
   CONFIG.MC_TRFCPB {140000} \
   CONFIG.MC_TRFCPBMIN {140000} \
   CONFIG.MC_TRP {0} \
   CONFIG.MC_TRPAB {21000} \
   CONFIG.MC_TRPABMIN {21000} \
   CONFIG.MC_TRPAB_nCK {34} \
   CONFIG.MC_TRPMIN {0} \
   CONFIG.MC_TRPPB {18000} \
   CONFIG.MC_TRPPBMIN {18000} \
   CONFIG.MC_TRPPB_nCK {29} \
   CONFIG.MC_TRPRE {1.8} \
   CONFIG.MC_TRRD {10000} \
   CONFIG.MC_TRRDMIN {10000} \
   CONFIG.MC_TRRD_L {0} \
   CONFIG.MC_TRRD_L_MIN {0} \
   CONFIG.MC_TRRD_S {0} \
   CONFIG.MC_TRRD_S_MIN {0} \
   CONFIG.MC_TRRD_nCK {16} \
   CONFIG.MC_TRTP_nCK {12} \
   CONFIG.MC_TWPRE {1.8} \
   CONFIG.MC_TWPST {0.4} \
   CONFIG.MC_TWR {18000} \
   CONFIG.MC_TWRMIN {18000} \
   CONFIG.MC_TWR_nCK {29} \
   CONFIG.MC_TWTR {10000} \
   CONFIG.MC_TWTRMIN {10000} \
   CONFIG.MC_TWTR_L {0} \
   CONFIG.MC_TWTR_S {0} \
   CONFIG.MC_TWTR_S_MIN {0} \
   CONFIG.MC_TWTR_nCK {16} \
   CONFIG.MC_TXP {12} \
   CONFIG.MC_TXPMIN {12} \
   CONFIG.MC_TXPR {0} \
   CONFIG.MC_TZQCAL {1000000} \
   CONFIG.MC_TZQCAL_div4 {400} \
   CONFIG.MC_TZQCS_ITVL {0} \
   CONFIG.MC_TZQLAT {30000} \
   CONFIG.MC_TZQLATMIN {30000} \
   CONFIG.MC_TZQLAT_div4 {12} \
   CONFIG.MC_TZQLAT_nCK {48} \
   CONFIG.MC_TZQ_START_ITVL {1000000000} \
   CONFIG.MC_USER_DEFINED_ADDRESS_MAP {16RA-3BA-10CA} \
   CONFIG.MC_WRITE_BANDWIDTH {6400.0} \
   CONFIG.MC_XPLL_CLKOUT1_PERIOD {1250} \
   CONFIG.MC_XPLL_CLKOUT1_PHASE {238.176} \
   CONFIG.NUM_CLKS {6} \
   CONFIG.NUM_MC {1} \
   CONFIG.NUM_MCP {1} \
   CONFIG.NUM_MI {0} \
   CONFIG.NUM_SI {6} \
   CONFIG.sys_clk0_BOARD_INTERFACE {lpddr4_sma_clk1} \
 ] $axi_noc_0

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5}} } \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S04_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S05_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk5]

  # Create instance: versal_cips_0, and set properties
  set versal_cips_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:2.1 versal_cips_0 ]
  set_property -dict [ list \
   CONFIG.CPM_PCIE0_AXISTEN_IF_RX_PARITY_EN {0} \
   CONFIG.CPM_PCIE0_AXISTEN_IF_WIDTH {64} \
   CONFIG.CPM_PCIE0_PF0_CFG_DEV_ID {A03F} \
   CONFIG.CPM_PCIE0_PF0_MSIX_CAP_TABLE_SIZE {001} \
   CONFIG.CPM_PCIE0_PF0_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE0_PF0_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE0_PF0_USE_CLASS_CODE_LOOKUP_ASSISTANT {0} \
   CONFIG.CPM_PCIE0_PF1_BASE_CLASS_VALUE {05} \
   CONFIG.CPM_PCIE0_PF1_CFG_DEV_ID {A13F} \
   CONFIG.CPM_PCIE0_PF1_INTERFACE_VALUE {00} \
   CONFIG.CPM_PCIE0_PF1_MSIX_CAP_TABLE_SIZE {001} \
   CONFIG.CPM_PCIE0_PF1_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE0_PF1_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE0_PF1_SUB_CLASS_VALUE {80} \
   CONFIG.CPM_PCIE0_PF1_USE_CLASS_CODE_LOOKUP_ASSISTANT {1} \
   CONFIG.CPM_PCIE0_PF2_BASE_CLASS_VALUE {05} \
   CONFIG.CPM_PCIE0_PF2_CFG_DEV_ID {A23F} \
   CONFIG.CPM_PCIE0_PF2_INTERFACE_VALUE {00} \
   CONFIG.CPM_PCIE0_PF2_MSIX_CAP_TABLE_SIZE {001} \
   CONFIG.CPM_PCIE0_PF2_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE0_PF2_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE0_PF2_SUB_CLASS_VALUE {80} \
   CONFIG.CPM_PCIE0_PF2_USE_CLASS_CODE_LOOKUP_ASSISTANT {1} \
   CONFIG.CPM_PCIE0_PF3_BASE_CLASS_VALUE {05} \
   CONFIG.CPM_PCIE0_PF3_CFG_DEV_ID {A33F} \
   CONFIG.CPM_PCIE0_PF3_INTERFACE_VALUE {00} \
   CONFIG.CPM_PCIE0_PF3_MSIX_CAP_TABLE_SIZE {001} \
   CONFIG.CPM_PCIE0_PF3_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE0_PF3_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE0_PF3_SUB_CLASS_VALUE {80} \
   CONFIG.CPM_PCIE0_PF3_USE_CLASS_CODE_LOOKUP_ASSISTANT {1} \
   CONFIG.CPM_PCIE0_USER_CLK_FREQ {125_MHz} \
   CONFIG.CPM_PCIE1_AXISTEN_IF_RX_PARITY_EN {0} \
   CONFIG.CPM_PCIE1_AXISTEN_IF_WIDTH {64} \
   CONFIG.CPM_PCIE1_PF0_CFG_DEV_ID {A034} \
   CONFIG.CPM_PCIE1_PF0_CLASS_CODE {0} \
   CONFIG.CPM_PCIE1_PF0_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE1_PF0_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE1_PF0_USE_CLASS_CODE_LOOKUP_ASSISTANT {0} \
   CONFIG.CPM_PCIE1_PF1_BASE_CLASS_VALUE {05} \
   CONFIG.CPM_PCIE1_PF1_CFG_DEV_ID {A134} \
   CONFIG.CPM_PCIE1_PF1_INTERFACE_VALUE {00} \
   CONFIG.CPM_PCIE1_PF1_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE1_PF1_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE1_PF1_SUB_CLASS_VALUE {80} \
   CONFIG.CPM_PCIE1_PF1_USE_CLASS_CODE_LOOKUP_ASSISTANT {1} \
   CONFIG.CPM_PCIE1_PF2_BASE_CLASS_VALUE {05} \
   CONFIG.CPM_PCIE1_PF2_CFG_DEV_ID {A234} \
   CONFIG.CPM_PCIE1_PF2_INTERFACE_VALUE {00} \
   CONFIG.CPM_PCIE1_PF2_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE1_PF2_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE1_PF2_SUB_CLASS_VALUE {80} \
   CONFIG.CPM_PCIE1_PF2_USE_CLASS_CODE_LOOKUP_ASSISTANT {1} \
   CONFIG.CPM_PCIE1_PF3_BASE_CLASS_VALUE {05} \
   CONFIG.CPM_PCIE1_PF3_CFG_DEV_ID {A334} \
   CONFIG.CPM_PCIE1_PF3_INTERFACE_VALUE {00} \
   CONFIG.CPM_PCIE1_PF3_SRIOV_VF_DEVICE_ID {0} \
   CONFIG.CPM_PCIE1_PF3_SUB_CLASS_INTF_MENU {Other_memory_controller} \
   CONFIG.CPM_PCIE1_PF3_SUB_CLASS_VALUE {80} \
   CONFIG.CPM_PCIE1_PF3_USE_CLASS_CODE_LOOKUP_ASSISTANT {1} \
   CONFIG.CPM_PCIE1_USER_CLK_FREQ {125_MHz} \
   CONFIG.PMC_CRP_DFT_OSC_REF_CTRL_ACT_FREQMHZ {400} \
   CONFIG.PMC_CRP_I2C_REF_CTRL_ACT_FREQMHZ {99.999001} \
   CONFIG.PMC_CRP_PL0_REF_CTRL_ACT_FREQMHZ {333.329987} \
   CONFIG.PMC_CRP_QSPI_REF_CTRL_ACT_FREQMHZ {299.997009} \
   CONFIG.PMC_CRP_SDIO1_REF_CTRL_ACT_FREQMHZ {199.998001} \
   CONFIG.PMC_CRP_SD_DLL_REF_CTRL_ACT_FREQMHZ {1199.988037} \
   CONFIG.PMC_CRP_TEST_PATTERN_REF_CTRL_ACT_FREQMHZ {200} \
   CONFIG.PMC_GPIO0_MIO_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_GPIO1_MIO_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_I2CPMC_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_I2CPMC_PERIPHERAL_IO {PMC_MIO 46 .. 47} \
   CONFIG.PMC_MIO_0_DIRECTION {out} \
   CONFIG.PMC_MIO_0_SCHMITT {1} \
   CONFIG.PMC_MIO_10_DIRECTION {inout} \
   CONFIG.PMC_MIO_11_DIRECTION {inout} \
   CONFIG.PMC_MIO_12_DIRECTION {out} \
   CONFIG.PMC_MIO_12_SCHMITT {1} \
   CONFIG.PMC_MIO_13_DIRECTION {out} \
   CONFIG.PMC_MIO_13_SCHMITT {1} \
   CONFIG.PMC_MIO_14_DIRECTION {inout} \
   CONFIG.PMC_MIO_15_DIRECTION {inout} \
   CONFIG.PMC_MIO_16_DIRECTION {inout} \
   CONFIG.PMC_MIO_17_DIRECTION {inout} \
   CONFIG.PMC_MIO_19_DIRECTION {inout} \
   CONFIG.PMC_MIO_1_DIRECTION {inout} \
   CONFIG.PMC_MIO_20_DIRECTION {inout} \
   CONFIG.PMC_MIO_21_DIRECTION {inout} \
   CONFIG.PMC_MIO_22_DIRECTION {inout} \
   CONFIG.PMC_MIO_24_DIRECTION {out} \
   CONFIG.PMC_MIO_24_SCHMITT {1} \
   CONFIG.PMC_MIO_26_DIRECTION {inout} \
   CONFIG.PMC_MIO_27_DIRECTION {inout} \
   CONFIG.PMC_MIO_29_DIRECTION {inout} \
   CONFIG.PMC_MIO_2_DIRECTION {inout} \
   CONFIG.PMC_MIO_30_DIRECTION {inout} \
   CONFIG.PMC_MIO_31_DIRECTION {inout} \
   CONFIG.PMC_MIO_32_DIRECTION {inout} \
   CONFIG.PMC_MIO_33_DIRECTION {inout} \
   CONFIG.PMC_MIO_34_DIRECTION {inout} \
   CONFIG.PMC_MIO_35_DIRECTION {inout} \
   CONFIG.PMC_MIO_36_DIRECTION {inout} \
   CONFIG.PMC_MIO_37_DIRECTION {out} \
   CONFIG.PMC_MIO_37_OUTPUT_DATA {high} \
   CONFIG.PMC_MIO_37_USAGE {GPIO} \
   CONFIG.PMC_MIO_3_DIRECTION {inout} \
   CONFIG.PMC_MIO_40_DIRECTION {out} \
   CONFIG.PMC_MIO_40_SCHMITT {1} \
   CONFIG.PMC_MIO_43_DIRECTION {out} \
   CONFIG.PMC_MIO_43_SCHMITT {1} \
   CONFIG.PMC_MIO_44_DIRECTION {inout} \
   CONFIG.PMC_MIO_45_DIRECTION {inout} \
   CONFIG.PMC_MIO_46_DIRECTION {inout} \
   CONFIG.PMC_MIO_47_DIRECTION {inout} \
   CONFIG.PMC_MIO_4_DIRECTION {inout} \
   CONFIG.PMC_MIO_5_DIRECTION {out} \
   CONFIG.PMC_MIO_5_SCHMITT {1} \
   CONFIG.PMC_MIO_6_DIRECTION {out} \
   CONFIG.PMC_MIO_6_SCHMITT {1} \
   CONFIG.PMC_MIO_7_DIRECTION {out} \
   CONFIG.PMC_MIO_7_SCHMITT {1} \
   CONFIG.PMC_MIO_8_DIRECTION {inout} \
   CONFIG.PMC_MIO_9_DIRECTION {inout} \
   CONFIG.PMC_MIO_TREE_PERIPHERALS { \
     0#Enet 0 \
     0#Enet 0 \
     0#Enet 0 \
     0#Enet 0 \
     0#Enet 0 \
     0#Enet 0 \
     0#Enet 0 \
     0#SD1/eMMC1#SD1/eMMC1#SD1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#GPIO 1###CAN \
     0#UART 0#I2C \
     0#USB 0#USB \
     0#USB 0#USB \
     0#USB 0#USB \
     0#USB 0#USB \
     0#USB 0#USB \
     0#USB 0#USB \
     1#CAN 1#UART \
     1#Enet 1#Enet \
     1#Enet 1#Enet \
     1#Enet 1#Enet \
     1#Enet 1#Enet \
     1#Enet 1#Enet \
     1#Enet 1#Enet \
     1#I2C 1#i2c_pmc#i2c_pmc#####Enet \
     QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#Loopback Clk#QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#USB \
   } \
   CONFIG.PMC_MIO_TREE_SIGNALS {qspi0_clk#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_io[0]#qspi0_cs_b#qspi_lpbk#qspi1_cs_b#qspi1_io[0]#qspi1_io[1]#qspi1_io[2]#qspi1_io[3]#qspi1_clk#usb2phy_reset#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_tx_data[2]#ulpi_tx_data[3]#ulpi_clk#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#ulpi_dir#ulpi_stp#ulpi_nxt#clk#dir1/data[7]#detect#cmd#data[0]#data[1]#data[2]#data[3]#sel/data[4]#dir_cmd/data[5]#dir0/data[6]#gpio_1_pin[37]###phy_tx#phy_rx#rxd#txd#scl#sda#scl#sda#####rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem0_mdc#gem0_mdio} \
   CONFIG.PMC_OSPI_PERIPHERAL_ENABLE {0} \
   CONFIG.PMC_QSPI_GRP_FBCLK_ENABLE {1} \
   CONFIG.PMC_QSPI_PERIPHERAL_DATA_MODE {x4} \
   CONFIG.PMC_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_QSPI_PERIPHERAL_MODE {Dual Parallel} \
   CONFIG.PMC_SD1_DATA_TRANSFER_MODE {8Bit} \
   CONFIG.PMC_SD1_GRP_CD_ENABLE {1} \
   CONFIG.PMC_SD1_GRP_CD_IO {PMC_MIO 28} \
   CONFIG.PMC_SD1_GRP_POW_ENABLE {0} \
   CONFIG.PMC_SD1_GRP_WP_ENABLE {0} \
   CONFIG.PMC_SD1_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_SD1_PERIPHERAL_IO {PMC_MIO 26 .. 36} \
   CONFIG.PMC_SD1_SLOT_TYPE {SD 3.0} \
   CONFIG.PMC_SD1_SPEED_MODE {high speed} \
   CONFIG.PMC_USE_PMC_NOC_AXI0 {1} \
   CONFIG.PS_CAN1_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_CAN1_PERIPHERAL_IO {PMC_MIO 40 .. 41} \
   CONFIG.PS_CRF_DBG_TRACE_CTRL_FREQMHZ {300} \
   CONFIG.PS_CRL_CAN1_REF_CTRL_ACT_FREQMHZ {149.998505} \
   CONFIG.PS_CRL_CAN1_REF_CTRL_DIVISOR0 {8} \
   CONFIG.PS_CRL_CAN1_REF_CTRL_FREQMHZ {150} \
   CONFIG.PS_CRL_GEM0_REF_CTRL_ACT_FREQMHZ {124.998749} \
   CONFIG.PS_CRL_GEM0_REF_CTRL_DIVISOR0 {8} \
   CONFIG.PS_CRL_GEM1_REF_CTRL_ACT_FREQMHZ {124.998749} \
   CONFIG.PS_CRL_GEM1_REF_CTRL_DIVISOR0 {8} \
   CONFIG.PS_CRL_GEM_TSU_REF_CTRL_ACT_FREQMHZ {249.997498} \
   CONFIG.PS_CRL_GEM_TSU_REF_CTRL_DIVISOR0 {4} \
   CONFIG.PS_CRL_I2C1_REF_CTRL_ACT_FREQMHZ {99.999001} \
   CONFIG.PS_CRL_UART0_REF_CTRL_ACT_FREQMHZ {99.999001} \
   CONFIG.PS_CRL_USB0_BUS_REF_CTRL_ACT_FREQMHZ {59.999401} \
   CONFIG.PS_CRL_USB0_BUS_REF_CTRL_DIVISOR0 {20} \
   CONFIG.PS_CRL_USB0_BUS_REF_CTRL_FREQMHZ {60} \
   CONFIG.PS_CRL_USB3_DUAL_REF_CTRL_ACT_FREQMHZ {100} \
   CONFIG.PS_CRL_USB3_DUAL_REF_CTRL_DIVISOR0 {100} \
   CONFIG.PS_CRL_USB3_DUAL_REF_CTRL_FREQMHZ {100} \
   CONFIG.PS_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PS_ENET0_GRP_MDIO_IO {PS_MIO 24 .. 25} \
   CONFIG.PS_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_ENET0_PERIPHERAL_IO {PS_MIO 0 .. 11} \
   CONFIG.PS_ENET1_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_ENET1_PERIPHERAL_IO {PS_MIO 12 .. 23} \
   CONFIG.PS_GEN_IPI_0_ENABLE {1} \
   CONFIG.PS_GEN_IPI_1_ENABLE {1} \
   CONFIG.PS_GEN_IPI_2_ENABLE {1} \
   CONFIG.PS_GEN_IPI_3_ENABLE {1} \
   CONFIG.PS_GEN_IPI_4_ENABLE {1} \
   CONFIG.PS_GEN_IPI_5_ENABLE {1} \
   CONFIG.PS_GEN_IPI_6_ENABLE {1} \
   CONFIG.PS_GEN_IPI_PMCNOBUF_ENABLE {1} \
   CONFIG.PS_GEN_IPI_PMC_ENABLE {1} \
   CONFIG.PS_GEN_IPI_PSM_ENABLE {1} \
   CONFIG.PS_GPIO2_MIO_PERIPHERAL_ENABLE {0} \
   CONFIG.PS_I2C1_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_I2C1_PERIPHERAL_IO {PMC_MIO 44 .. 45} \
   CONFIG.PS_MIO_0_DIRECTION {out} \
   CONFIG.PS_MIO_0_SCHMITT {1} \
   CONFIG.PS_MIO_12_DIRECTION {out} \
   CONFIG.PS_MIO_12_SCHMITT {1} \
   CONFIG.PS_MIO_13_DIRECTION {out} \
   CONFIG.PS_MIO_13_SCHMITT {1} \
   CONFIG.PS_MIO_14_DIRECTION {out} \
   CONFIG.PS_MIO_14_SCHMITT {1} \
   CONFIG.PS_MIO_15_DIRECTION {out} \
   CONFIG.PS_MIO_15_SCHMITT {1} \
   CONFIG.PS_MIO_16_DIRECTION {out} \
   CONFIG.PS_MIO_16_SCHMITT {1} \
   CONFIG.PS_MIO_17_DIRECTION {out} \
   CONFIG.PS_MIO_17_SCHMITT {1} \
   CONFIG.PS_MIO_1_DIRECTION {out} \
   CONFIG.PS_MIO_1_SCHMITT {1} \
   CONFIG.PS_MIO_24_DIRECTION {out} \
   CONFIG.PS_MIO_24_SCHMITT {1} \
   CONFIG.PS_MIO_25_DIRECTION {inout} \
   CONFIG.PS_MIO_2_DIRECTION {out} \
   CONFIG.PS_MIO_2_SCHMITT {1} \
   CONFIG.PS_MIO_3_DIRECTION {out} \
   CONFIG.PS_MIO_3_SCHMITT {1} \
   CONFIG.PS_MIO_4_DIRECTION {out} \
   CONFIG.PS_MIO_4_SCHMITT {1} \
   CONFIG.PS_MIO_5_DIRECTION {out} \
   CONFIG.PS_MIO_5_SCHMITT {1} \
   CONFIG.PS_NUM_FABRIC_RESETS {1} \
   CONFIG.PS_PCIE_RESET_ENABLE {1} \
   CONFIG.PS_PCIE_RESET_IO {PS_MIO 18 .. 19} \
   CONFIG.PS_TTC0_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_TTC0_REF_CTRL_ACT_FREQMHZ {149.998505} \
   CONFIG.PS_TTC0_REF_CTRL_FREQMHZ {149.998505} \
   CONFIG.PS_TTC3_PERIPHERAL_ENABLE {0} \
   CONFIG.PS_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_UART0_PERIPHERAL_IO {PMC_MIO 42 .. 43} \
   CONFIG.PS_USB3_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_USE_M_AXI_GP0 {0} \
   CONFIG.PS_USE_M_AXI_GP2 {0} \
   CONFIG.PS_USE_PMCPL_CLK0 {1} \
   CONFIG.PS_USE_PS_NOC_CCI {1} \
   CONFIG.PS_USE_PS_NOC_RPU_0 {1} \
   CONFIG.PS_USE_S_AXI_GP0 {0} \
   CONFIG.PS_USE_S_AXI_GP2 {0} \
   CONFIG.PS_USE_S_AXI_GP4 {0} \
   CONFIG.SMON_TEMP_AVERAGING_SAMPLES {8} \
 ] $versal_cips_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_noc_0_CH0_LPDDR4_0 [get_bd_intf_ports ch0_lpddr4_c0] [get_bd_intf_pins axi_noc_0/CH0_LPDDR4_0]
  connect_bd_intf_net -intf_net axi_noc_0_CH1_LPDDR4_0 [get_bd_intf_ports ch1_lpddr4_c0] [get_bd_intf_pins axi_noc_0/CH1_LPDDR4_0]
  connect_bd_intf_net -intf_net lpddr4_sma_clk1_1 [get_bd_intf_ports lpddr4_sma_clk1] [get_bd_intf_pins axi_noc_0/sys_clk0]
  connect_bd_intf_net -intf_net versal_cips_0_FPD_CCI_NOC_0 [get_bd_intf_pins axi_noc_0/S02_AXI] [get_bd_intf_pins versal_cips_0/FPD_CCI_NOC_0]
  connect_bd_intf_net -intf_net versal_cips_0_FPD_CCI_NOC_1 [get_bd_intf_pins axi_noc_0/S03_AXI] [get_bd_intf_pins versal_cips_0/FPD_CCI_NOC_1]
  connect_bd_intf_net -intf_net versal_cips_0_FPD_CCI_NOC_2 [get_bd_intf_pins axi_noc_0/S04_AXI] [get_bd_intf_pins versal_cips_0/FPD_CCI_NOC_2]
  connect_bd_intf_net -intf_net versal_cips_0_FPD_CCI_NOC_3 [get_bd_intf_pins axi_noc_0/S05_AXI] [get_bd_intf_pins versal_cips_0/FPD_CCI_NOC_3]
  connect_bd_intf_net -intf_net versal_cips_0_NOC_LPD_AXI_0 [get_bd_intf_pins axi_noc_0/S01_AXI] [get_bd_intf_pins versal_cips_0/NOC_LPD_AXI_0]
  connect_bd_intf_net -intf_net versal_cips_0_PMC_NOC_AXI_0 [get_bd_intf_pins axi_noc_0/S00_AXI] [get_bd_intf_pins versal_cips_0/PMC_NOC_AXI_0]

  # Create port connections
  connect_bd_net -net versal_cips_0_fpd_cci_noc_axi0_clk [get_bd_pins axi_noc_0/aclk2] [get_bd_pins versal_cips_0/fpd_cci_noc_axi0_clk]
  connect_bd_net -net versal_cips_0_fpd_cci_noc_axi1_clk [get_bd_pins axi_noc_0/aclk3] [get_bd_pins versal_cips_0/fpd_cci_noc_axi1_clk]
  connect_bd_net -net versal_cips_0_fpd_cci_noc_axi2_clk [get_bd_pins axi_noc_0/aclk4] [get_bd_pins versal_cips_0/fpd_cci_noc_axi2_clk]
  connect_bd_net -net versal_cips_0_fpd_cci_noc_axi3_clk [get_bd_pins axi_noc_0/aclk5] [get_bd_pins versal_cips_0/fpd_cci_noc_axi3_clk]
  connect_bd_net -net versal_cips_0_lpd_axi_noc_clk [get_bd_pins axi_noc_0/aclk1] [get_bd_pins versal_cips_0/lpd_axi_noc_clk]
  connect_bd_net -net versal_cips_0_pmc_axi_noc_axi0_clk [get_bd_pins axi_noc_0/aclk0] [get_bd_pins versal_cips_0/pmc_axi_noc_axi0_clk]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI0] [get_bd_addr_segs axi_noc_0/S02_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI1] [get_bd_addr_segs axi_noc_0/S03_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI2] [get_bd_addr_segs axi_noc_0/S04_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI3] [get_bd_addr_segs axi_noc_0/S05_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_PMC] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_RPU0] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


