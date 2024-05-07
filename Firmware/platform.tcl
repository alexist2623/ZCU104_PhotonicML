# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Jeonghyun\Lab\ZCU104\VITIS\ZCU104_IRQ\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Jeonghyun\Lab\ZCU104\VITIS\ZCU104_IRQ\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {ZCU104_IRQ}\
-hw {C:\Jeonghyun\Lab\ZCU104\VITIS\ZCU104_IRQ.xsa}\
-proc {psu_cortexa53_0} -os {standalone} -arch {64-bit} -fsbl-target {psu_cortexa53_0} -out {C:/Jeonghyun/Lab/ZCU104/VITIS}

platform write
platform generate -domains 
platform active {ZCU104_IRQ}
bsp reload
bsp setlib -name libmetal -ver 2.1
bsp setlib -name lwip211 -ver 1.3
bsp setlib -name xilffs -ver 4.4
bsp setlib -name xilflash -ver 4.8
bsp write
bsp reload
catch {bsp regenerate}
domain create -name {psu_cortexa53_1} -os {standalone} -proc {psu_cortexa53_1} -arch {64-bit} -display-name {psu_cortexa53_1} -desc {} -runtime {cpp}
platform generate -domains 
platform write
domain -report -json
bsp reload
bsp setlib -name xilflash -ver 4.8
bsp setlib -name xilffs -ver 4.4
bsp write
bsp reload
catch {bsp regenerate}
