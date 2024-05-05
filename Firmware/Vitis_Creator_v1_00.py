# -*- coding: utf-8 -*-
"""
Created on Tue Sep 26 19:40:08 2023

@author: QC109_4
"""
import os
import re
import shutil
import subprocess

class Vitis_maker:
    def __init__(self):
        print('make vitis project...')
        # self.vitis_dir = r'E:\Xilinx\Vitis\2020.2\bin\xsct.bat'
        # self.git_dir = r'E:\RFSoC\GIT'
        self.vitis_dir = r'C:\Xilinx\Vitis\2020.2\bin\xsct.bat'
        self.git_dir = r'C:\Jeonghyun\SNU_GIT'
        self.tcl_commands = ''
        self.xsa_dir = os.path.join(self.git_dir,'Vivado_prj_manager','Vitis_main','RFSoC_Main_blk_wrapper.xsa')
        self.bsp_lib_dir = os.path.join(self.git_dir,r'RFSoC\RFSoC_Design_V1_1\VITIS\RFSoC_Firmware_plt\export\RFSoC_Firmware_plt\sw\RFSoC_Firmware_plt\standalone_domain\bsplib')
        self.bsp_include_dir = os.path.join(self.git_dir,r'RFSoC\RFSoC_Design_V1_1\VITIS\RFSoC_Firmware_plt\export\RFSoC_Firmware_plt\sw\RFSoC_Firmware_plt\standalone_domain\bspinclude')
        self.xilinx_include_dir = os.path.join(self.git_dir,r'Vivado_prj_manager\Compiler\Xilinx_Include')
        self.skeleton_dir = os.path.join(self.git_dir,r'Vivado_prj_manager\Compiler\C_Code\skeleton_code')
        self.TCP_firmware_dir = os.path.join(self.git_dir,'Vivado_prj_manager','Vitis_main','RFSoC_Firmware_0')
        self.realtime_firmware_dir = os.path.join(self.git_dir,'Vivado_prj_manager','Vitis_main','RFSoC_Firmware_1')
        self.realtime_linker_dir = os.path.join(self.git_dir,'Vivado_prj_manager','Vitis_main','RFSoC_Firmware_1_linker')
        self.target_dir = os.path.join(self.git_dir,'RFSoC','RFSoC_Design_V1_1','VITIS')
            
        self.ensure_directory_exists(self.target_dir)
    
    def ensure_directory_exists(self, directory_dir):
        if not os.path.exists(directory_dir):
            try:
                os.makedirs(directory_dir)
                print(f"Directory {directory_dir} created.")
            except OSError as error:
                print(f"Error creating directory {directory_dir}: {error}")
        else:
            print(f"Directory {directory_dir} already exists.")
        
    def copy_bsp_include(self):
        # Define the source directory and the destination path
        source_directory = self.bsp_include_dir
        destination_directory = os.path.join(self.xilinx_include_dir,'bspinclude')
        
        if os.path.exists(destination_directory):
            shutil.rmtree(destination_directory)
            print('Delete previous BSP include')
            # Copy the entire directory
        shutil.copytree(source_directory, destination_directory)
        
        print(f"BSP Include directory Copied the entire directory from {source_directory} to {destination_directory}.")
        
    def copy_bsp_lib(self):
        # Define the source directory and the destination path
        source_directory = self.bsp_lib_dir
        destination_directory = os.path.join(self.xilinx_include_dir,'bsplib')
        
        # Copy the entire directory
        if os.path.exists(destination_directory):
            shutil.rmtree(destination_directory)
            print('Delete previous bsp lib')
        shutil.copytree(source_directory, destination_directory)
        
        print(f"BSP Lib directory Copied the entire directory from {source_directory} to {destination_directory}.")
        
    def run_vitis_tcl(self):
        file_dir = f'{self.target_dir}/make_project.tcl'
        self.tcl_commands = self.tcl_commands.replace('\\','/')
        with open(file_dir, 'w') as tcl_file:
            tcl_file.write(self.tcl_commands)
        # Start Vitis in batch mode and pass the TCL commands as input
        process = subprocess.Popen([self.vitis_dir, file_dir],
                                   stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, text=True, cwd=self.target_dir)
    
    
        while process.poll() == None:
            out = process.stdout.readline()
            print(out, end='')
            
        # Wait for the process to complete
        stdout, stderr = process.communicate()
    
        # Print the output and error messages
        print(stdout)
        print(stderr)
        
    def make_vitis_platform(self):
        self.tcl_commands += f"""
platform create -name "RFSoC_Firmware_plt" -hw "{self.xsa_dir}" -proc psu_cortexa53_0 -os standalone -arch 64-bit -fsbl-target psu_cortexa53_0
platform read {os.path.join(self.target_dir,'RFSoC_Firmware_plt','platform.spr')}
platform active {{RFSoC_Firmware_plt}}
domain create -name {{psu_cortexa53_1}} -os {{standalone}} -proc {{psu_cortexa53_1}} -arch {{64-bit}} -display-name {{psu_cortexa53_1}} -desc {{}} -runtime {{cpp}}
platform generate -domains psu_cortexa53_1 
domain active standalone_domain
domain active psu_cortexa53_1

platform write
platform generate -domains 
platform active RFSoC_Firmware_plt
domain active standalone_domain
bsp reload
bsp setlib -name libmetal -ver 2.1
bsp setlib -name lwip211 -ver 1.3
bsp setlib -name xilpm -ver 3.2
bsp config compiler "aarch64-none-elf-gcc"
bsp write
bsp reload
catch {{bsp regenerate}}
platform generate
platform active RFSoC_Firmware_plt
platform generate -domains
        """
        # domain create -name a53_Standalone -os standalone -proc psu_cortexa53_0
        # platform generate -domains a53_standalone
        
        self.tcl_commands += '\n'
        
    def get_all_files_in_directory(self, directory,file_type):
        file_list = []
        is_filetype = False
        
        for root, dirs, files in os.walk(directory):
            for file in files:
                for types_ in file_type:
                    if file.endswith(types_):
                        is_filetype = True
                if is_filetype:
                    file_list.append(os.path.join(root, file))
                is_filetype = False
        return file_list
    
    def make_vitis_application(self):
        self.tcl_commands += f"""
app create -name RFSoC_Firmware_app -platform RFSoC_Firmware_plt -proc psu_cortexa53_0 -os standalone -lang C -template {{Empty Application}} -domain standalone_domain
app create -name RealTime_Firmware_app -sysproj RFSoC_Firmware_app_system -proc psu_cortexa53_1 -os standalone -lang C -template {{Empty Application}} -domain psu_cortexa53_1
importsources -name RFSoC_Firmware_app -path "{self.TCP_firmware_dir}" -soft-link
importsources -name RealTime_Firmware_app -path "{self.realtime_firmware_dir}" -soft-link
importsources -name RealTime_Firmware_app -path "{self.realtime_linker_dir}\lscript.ld"
            """
        
        self.tcl_commands += '\n'
        
    def set_workspace(self):
        self.tcl_commands += f'setws \"{self.target_dir}\"'
        self.tcl_commands += '\n'
            
if __name__ == "__main__":
    vtm = Vitis_maker()
    
    vtm.set_workspace()
    vtm.make_vitis_platform()
    vtm.make_vitis_application()
    vtm.run_vitis_tcl()