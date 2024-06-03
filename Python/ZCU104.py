# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 18:01:13 2023

@author: QC109_4
"""
import TCPClient_v1_00 as TCP
import time

class ZCU104:
    def __init__(self, IPAddress = '192.168.1.10', TCPPort = 7):    
        self.tcp = TCP.TCP_Client(IPAddress = '192.168.1.10', TCPPort = 7)
        
    def connect(self)->None:
        self.tcp.connect()
        print("RFSoC is connected with TCP")
        
           
    def disconnect(self)->None:
        self.tcp.disconnect()
        
    def startDisplay(self)->None:
        """
        START DISPLAY

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("#START_DISPLAY#")
        a = self.tcp.read()
        print(a)
    def stopDisplay(self)->None:
        """
        STOP DISPLAY

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("#STOP_DISPLAY#")
        a = self.tcp.read()
        print(a)
        
    def loadSDCard(self)->None:
        """
        LOAD SD CARD

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("#LOAD_SD_CARD#")
        a = self.tcp.read()
        print(a)
        
    def setNewImage(self)->None:
        """
        SET NEW IMAGE

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("#SET_NEW_IMAGE#")
        a = self.tcp.read()
        print(a)
        
    def setTest(
        self, 
        test_mode : int,
        test_data : int,
        start_X : int,
        start_Y : int,
        end_X : int,
        end_Y : int
    )->None:
        """
        SET NEW IMAGE

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write(f"#SET_TEST#{test_mode}#{test_data}#{start_X}#"
                       f"{start_Y}#{end_X}#{end_Y}#")
        a = self.tcp.read()
        print(a)
        
        
if __name__ == "__main__":
    zcu104 = ZCU104(IPAddress = '192.168.1.10', TCPPort = 7)
    zcu104.connect()
    # zcu104.setNewImage()
    # zcu104.loadSDCard()
    zcu104.setTest(1,255,0,0,550,434)
    # zcu104.setTest(1,255,0,0,1023,767)
    zcu104.disconnect()