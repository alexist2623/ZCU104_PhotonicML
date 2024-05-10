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
        
    def connect(self):
        self.tcp.connect()
        print("RFSoC is connected with TCP")
        
           
    def disconnect(self):
        self.tcp.disconnect()
        
    def startDisplay(self):
        """
        START DISPLAY

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("START DISPLAY")
        a = self.tcp.read()
        print(a)
    def stopDisplay(self):
        """
        STOP DISPLAY

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("STOP DISPLAY")
        a = self.tcp.read()
        print(a)
        
    def loadSDCard(self):
        """
        LOAD SD CARD

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("LOAD SD CARD")
        a = self.tcp.read()
        print(a)
        
    def setNewImage(self):
        """
        SET NEW IMAGE

        Args:
            None
        
        Returns:
            None

        """
        self.tcp.write("SET NEW IMAGE")
        a = self.tcp.read()
        print(a)
        
        
if __name__ == "__main__":
    zcu104 = ZCU104(IPAddress = '192.168.1.10', TCPPort = 7)
    zcu104.connect()
    zcu104.setNewImage()
    # zcu104.loadSDCard()
    zcu104.disconnect()