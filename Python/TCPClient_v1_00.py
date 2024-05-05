#!/usr/bin/python3
## -*- coding: latin-1 -*-

# Change log
# v1_00: Initial version

import os
import subprocess
import io
import time
import socket
import numpy as np

class TCP_Client:
    def __init__(self, defaultIPAddress = '192.168.1.10', defaultTCPPort = 7):
        self.IPAddress = defaultIPAddress
        self.TCPPort = defaultTCPPort


    def connect(self):
        """ Opens the device.
        
        Args:
            None
        
        Returns:
            None
        """
        print(self.IPAddress)
        print(self.TCPPort)
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.connect((self.IPAddress,self.TCPPort))
        self.socket.settimeout(20)
        
        
    def disconnect(self):
        self.socket.close()
        
    def write(self, commandWithoutNewline):
        """ Send the command.
        
        Args:
            commandWithoutNewline (unicode string): '\n' is automatically added,
                so it should not be added to the argument
        
        Returns:
            None
        """
        self.socket.send(bytes(commandWithoutNewline, 'latin-1'))

        
        

    def read(self):
        """ Reads data from the device.
        
        Args:
            None
        
        Returns:
            unicode string: received string
        """
        return (self.socket.recv(10000).decode('latin-1'))

class RFSoC:
    def __init__(self):    
        self.tcp = TCP_Client()
        
    def connect(self):
        self.tcp.connect()
        print("RFSoC is connected with TCP")
        
    def autoStart(self):
        #TimeController
        self.tcp.write("START")
        a = self.tcp.read()
        print(a)
        
        
    def disconnect(self):
        self.tcp.disconnect()
    

if __name__ == "__main__": 
    RFSoC = RFSoC()
    RFSoC.connect()
    RFSoC.autoEnd()