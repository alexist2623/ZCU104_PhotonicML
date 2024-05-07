# -*- coding: utf-8 -*-
"""
Created on Tue Sep 26 19:40:08 2023

@author: QC109_4
"""
import os
import re
import shutil
import subprocess
import argparse
import json

# This is Vitis Mother
class TVIM:
    common_path : str = None
    target_path : str = None
    vitis_path : str = None
    xsa_path : str = None
    
    tcl_code : str = ""
    
    def __init__(self):
        pass
    
    @classmethod
    def SetClassVars(cls, **kwargs):
        for key, value in kwargs.items():
            setattr(cls, key, value)
            
    @classmethod
    def ClearTCLCode(cls):
        cls.tcl_code = ""

# r'C:\Xilinx\Vitis\2020.2\bin\xsct.bat'
class VitisMaker(TVIM):
    def __init__(self):
        print('make vitis project...')
        self.platform_name : str = None
        self.app : list(VitisAppMaker) = []
            
        EnsureDirectoryExists(TVIM.target_path)
        
    def make_vitis_platform(self):
        TVIM.tcl_commands += (
            f"platform create -name \"{self.platform_name}\" -hw"
            f" \"{TVIM.xsa_path}\" -proc {self.app[0].proc} -os {self.app[0].os}"
            f" -arch {self.app[0].arch} -fsbl-target {self.app[0].proc}\n"
            "platform read"
            f" {os.path.join(TVIM.target_dir,self.platform_name,'platform.spr')}\n"
            f"platform active {{{self.platform_name}}}\n"
        )
    def make_vitis_Domain(self):
        for app in self.app[1:]:
            TVIM.tcl_commands += (
                "domain create -name {{{app.domain}}} -os {{{app.os}}}"
                " -proc {{{app.proc}}} -arch {{{app.arch}}} -display-name"
                " {{{app.app_name}}} -desc {{}} -runtime {{{app.lang}}}\n"
                "platform generate -domains {app.domain}\n"
            )
        TVIM.tcl_commands +=  f"domain active {self.app[0].os}_domain\n" 
        
        for app in self.app[1:]:
            TVIM.tcl_commands += "domain active {app.domain}\n"

        TVIM.tcl_commands += (
            "platform write\n"
            "platform generate -domains\n" 
        )
        TVIM.tcl_commands +=  f"domain active {self.app[0].os}_domain\n"
        TVIM.tcl_commands +=  "bsp reload\n"
        for lib_name, lib_ver in self.app[0].libs.items():
            TVIM.tcl_commands +=  f"bsp setlib -name {lib_name} -ver {lib_ver}\n"
        TVIM.tcl_commands +=  (
            "bsp config compiler \"aarch64-none-elf-gcc\"\n"
            "bsp write\n"
            "bsp reload\n"
            "catch {{bsp regenerate}}\n"
        )
        
        for app in self.app[1:]:
            TVIM.tcl_commands +=  f"domain active {app.os}_domain\n"
            TVIM.tcl_commands +=  "bsp reload\n"
            for lib_name, lib_ver in app.libs.items():
                TVIM.tcl_commands +=  f"bsp setlib -name {lib_name} -ver {lib_ver}\n"
            TVIM.tcl_commands +=  (
                "bsp config compiler \"aarch64-none-elf-gcc\"\n"
                "bsp write\n"
                "bsp reload\n"
                "catch {{bsp regenerate}}\n"
            )
    
    def make_vitis_application(self):
        TVIM.tcl_commands += (
            "app create -name {self.app[0].app_name}"
            " -platform {self.platform_name} -proc {self.app[0].proc}"
            " -os {self.app[0].os}"
            " -lang {self.app[0].lang}"
            " -template {{Empty Application}}"
            " -domain {self.app[0].os}_domain\n"
        )
        TVIM.tcl_commands += (
            "app create -name RealTime_Firmware_app -sysproj RFSoC_Firmware_app_system -proc psu_cortexa53_1 -os standalone -lang C -template {{Empty Application}} -domain psu_cortexa53_1\n"
            "importsources -name RFSoC_Firmware_app -path \"{self.TCP_firmware_dir}\" -soft-link\n"
            "importsources -name RealTime_Firmware_app -path \"{self.realtime_firmware_dir}\" -soft-link\n"
            "importsources -name RealTime_Firmware_app -path \"{self.realtime_linker_dir}\lscript.ld\"\n"
        )
        
    def set_workspace(self):
        TVIM.tcl_commands += f"setws \"{self.target_dir}\"\n"
        
class VitisAppMaker(TVIM):
    def __init__(self):
        self.app_name : str = None
        self.domain : str = None
        self.lang : str = None
        self.os : str = None
        self.proc : str = None
        self.arch : str = None
        self.libs : list(dict[str:str]) = []
    
def SetGlobalNamespace(json_file) -> None:
    with open(json_file, 'r') as file:
        data = json.load(file)
    TVIM.SetClassVars(**data)
    
def main(args : argparse.Namespace) -> None:
    # Use provided values or defaults
    configuration = args.config if args.config else 'configuration.json'
    verilog_json = (
        args.verilog_json if args.verilog_json 
        else 'vitis_json.json'
    )

    SetGlobalNamespace(configuration)
    vm = VitisMaker(verilog_json)
    vm.MakeTCL()
    
def RunVitisTCL(tcl_path) -> None:
    process = subprocess.Popen(
        [TVIM.vitis_path, "-mode", "batch", "-source", tcl_path],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, 
        universal_newlines=True, text=True
    )
    while process.poll() == None:
        out = process.stdout.readline()
        print(out, end='')
    stdout, stderr = process.communicate()
    print(stderr if stderr else 'Vitis ended with no error')
    
def CreateVitisMaker(json_file) -> VitisMaker:
    with open(json_file, 'r') as file:
        data = json.load(file)
    vm = VitisMaker(**data['platform'])
    for app_name, ip_data in data.get('app', {}).items():
        app_maker = VitisAppMaker(**ip_data)
        app_maker.app_name = app_name
        vm.app.append(app_maker)
    return vm

def EnsureDirectoryExists(directory_path) -> None:
    if not os.path.exists(directory_path):
        try:
            os.makedirs(directory_path)
            print(f"Directory {directory_path} created.")
        except OSError as error:
            print(f"Error creating directory {directory_path}: {error}")
    else:
        print(f"Directory {directory_path} already exists.")
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Make Vitis project from json meta file"
        )
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", 
        help="Increase output verbosity"
    )
    parser.add_argument("-c", "--config", help="Configuration file name")
    parser.add_argument("-f", "--vitis_json", help="Vitis JSON file name")
    args = parser.parse_args()
    main(args)