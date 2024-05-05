# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 18:01:13 2023

@author: QC109_4
"""
import TCPClient_v1_00 as TCP
import C_compiler as elf_maker
import python2C as interpreter
import time

class RFSoCManager(TCP.RFSoC):
    def __init__(self):
        super().__init__()
        # Interpreter object which convert code from python to C Code
        self.interpreter = interpreter.interpreter()
        # Compiler Object which compiles C Code which run on the RFSoC
        self.comp = elf_maker.Compiler()
        # Directory and file name which you want to run on the RFSoC
        self.file_name = 'RFSoC_Driver'
        # Set whether you will compile the code, or just send binary code to RFSoC
        self.do_compile = True
        self.comp.do_compile = self.do_compile
        
    def runRFSoC(self):
        """
        Compile the given code and run this binary file on the RFSoC CPU

        Args:
            None
        
        Returns:
            None

        """
        # Compile C Code in ../C_Code/
        self.comp.compileCode(self.file_name)
        
        # Read the ELF file
        elf_data = self.comp.readELFfile(self.file_name)
        
        # Send ELF binary data to RFSoC
        self.sendBin(self.comp.createTCPpacket())
        self.tcp.write("#BIN#run_binary#!EOL#");
        a = self.tcp.read()
        print(a)
        
    def setFileName(self, file_name):
        """
        Set File and Dirctory of C Code which you will run on the RFSoC
        Args:
            file_name: name of file which you want to run on the RFSoC
        
        Returns:
            None
        """
        self.file_name = file_name.replace('.cpp', '').replace('.c', '')
        
    def stopRFSoC(self):
        """
        Stop the CPU which is running binary code

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("#BIN#stop_binary#!EOL#")
        a = self.tcp.read()
        print(a)
        
    def read8bitData(self):
        """
        Read 8 bit data list from RFSoC
        Note that read data is little edian type.
        For instance 
        int64_t x = 0x010203040506
        is coverted to 
        [6,5,4,3,2,1,0,0]
        when we receive data
        
        Args:
            None
        
        Returns:
            received data from RFSoC in 8 bit int type

        """
        data_list = self.tcp.read()
        data_list = bytes(data_list,'latin-1')
        data_list = [i_ for i_ in data_list]
        print(data_list)
        # TCP transfer callback function. Note that if you don't run this code
        # RFSoC will jsut wait for callback.
        self.recvCallback()
        
        return data_list
        
    def read64bitData(self):
        """
        make 8 bit type data list to 64 bit data list
        Args:
            None
        
        Returns:
            data list in 64bit int type
        """
        data_list = self.read8bitData()
        data_64bit_list = []
        for index in range(len(data_list)>>3):
            data_64bit = (data_list[index * 8]) + (data_list[index * 8 + 1] << 8) +\
            (data_list[index * 8 + 2] << 16 )+ (data_list[index * 8 + 3] << 24)+\
            (data_list[index * 8 + 4] << 32 )+ (data_list[index * 8 + 5] << 40)+\
            (data_list[index * 8 + 6] << 48) + (data_list[index * 8 + 7] << 56)
            
            data_64bit_list.append(data_64bit)
           
        data_hex_list = [hex(i_) for i_ in data_64bit_list]
        print(data_hex_list)
        return data_64bit_list
    
    def close(self):
        """
        Disconnect TCP communication with RFSoC.
        Args:
            None
        
        Returns:
            None
        """
        self.disconnect()
        
if __name__ == "__main__":
    file_name = 'test_code_1'
    RFSoCManager = RFSoCManager()
    RFSoCManager.setFileName(file_name)
    RFSoCManager.connect()
    RFSoCManager.stopRFSoC()
    RFSoCManager.runRFSoC()
    # RFSoCManager.read64bitData()
    # RFSoCManager.read64bitData()
    
    # RFSoCManager.stopRFSoC()
    RFSoCManager.close()