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

proc vck190_create {} {
	setws ../Software/Vitis
	platform create -name vck190_wrapper -hw ../Hardware/vck190_es1_lpddr4/design_1_wrapper.xsa
	
	domain create -name psv_cortexa72_0 -os standalone -proc psv_cortexa72_0

	app create -name hello_a72_0 -sysproj vck190_system -platform vck190_wrapper -domain psv_cortexa72_0 -template {Hello World} -lang C	
}

proc vck190_build {} {
	setws ../Software/Vitis
	app build -name hello_a72_0
}

vck190_create
vck190_build
