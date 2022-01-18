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

# Create Vivado project
create_project vck190_es1_lpddr4 ../Hardware/vck190_es1_lpddr4 -part xcvc1902-vsva2197-2MP-e-S-es1

# Set the project device
set_property board_part xilinx.com:vck190_es:part0:1.1 [current_project]

# Source the BD file
source design_bd.tcl

make_wrapper -files [get_files ../Hardware/vck190_es1_lpddr4/vck190_es1_lpddr4.srcs/sources_1/bd/design_1/design_1.bd] -top

add_files -norecurse ../Hardware/vck190_es1_lpddr4/vck190_es1_lpddr4.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v

launch_runs impl_1 -to_step write_device_image -jobs 4

write_hw_platform -fixed -include_bit -force -file ../Hardware/vck190_es1_lpddr4/design_1_wrapper.xsa

