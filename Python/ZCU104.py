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

    def start_display(self)->None:
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
    def stop_display(self)->None:
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

    def load_sd_card(self)->None:
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

    def set_new_image(self)->None:
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

    def set_test(
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

    def set_camera_exposure_start(
        self,
        input_polarity : int,
        output_polarity : int,
        timer : int,
        event : int,
        delay : int
    ) -> None:
        self.tcp.write(f"#SET_CAM_EXP_START#{input_polarity}#{output_polarity}#{timer}#{event}#{delay}#")
        a = self.tcp.read()
        print(a)

    def set_camera_exposure_end(
        self,
        input_polarity : int,
        output_polarity : int,
        timer : int,
        event : int,
        delay : int
    ) -> None:
        self.tcp.write(
            f"#SET_CAM_EXP_END#{input_polarity}"
            f"#{output_polarity}#{timer}#{event}#{delay}#"
        )
        a = self.tcp.read()
        print(a)

    def send_uart(
        self,
        addr: int,
        addr_len: int,
        data: list[int]
    ) -> None:
        """
        Send UART data to Camera

        Args:
            addr (int): Address to send data
            addr_len (int): Address length 
                -0b00 : 2bytes
                -0b01 : 4bytes
                -0b10 : 6bytes
                -0b11 : 8bytes
            data (list[int]): Data to send
        
        Returns:
            None
        """
        # Send header
        self.tcp.write(f"#UART_SEND#{addr}#{addr_len}#{len(data)}#!EOL#")
        log = self.tcp.read()
        print(log)

        # Send actual byte data
        byte_data = bytes(data)
        self.tcp.send_raw(byte_data)
        log = self.tcp.read()
        print(log)

    def set_acquisition_trigger(self)->None:
        """
        Set acquisition as a hardware trigger mode

        Args:
            None
        
        Returns:
            None

        """
        self.send_uart(
            addr = 0x00040100,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x01]
        )

    def set_acqusition_source_cc1(self)->None:
        """
        Set acquisition source as CC1

        Args:
            None
        
        Returns:
            None

        """
        self.send_uart(
            addr = 0x00040140,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x09]
        )

    def set_frame_count(self, frame_count : int)->None:
        """
        Set frame count

        Args:
            frame_count (int): Frame count. Min is 1, and Max is 255
        
        Returns:
            None

        """
        self.send_uart(
            addr = 0x000400A0|0x04,
            addr_len = 0b11,
            data = [frame_count & 0xff]
        )

    def set_frame_tirgger(self)->None:
        """
        Set framer start as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040200,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x01]
        )

    def set_frame_trigger_source(self)->None:
        """
        Set frame trigger source as CC2
        """
        self.send_uart(
            addr = 0x00040240,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x0A]
        )

    def set_tap_1x3(self)->None:
        """
        Set cameralink tap configuartion as 1X3-1Y
        """
        self.send_uart(
            addr = 0x0720,
            addr_len = 0b00,
            data = [0x00, 0x00, 0x00, 0x07]
        )

    def cl_clock(self)->None:
        """
        Set cameralink clock to 82MHz
        """
        self.send_uart(
            addr = 0x0740,
            addr_len = 0b00,
            data = [0x00, 0x00, 0x00, 0x23]
        )

    def set_pixel_format(self)->None:
        """
        Set pixel format to mono8
        """
        self.send_uart(
            addr = 0x00030020,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x01]
        )

    def camera_init(self)->None:
        """
        Initialize camera
        """
        self.set_tap_1x3()
        self.set_pixel_format()
        self.cl_clock()
        self.set_acquisition_trigger()
        self.set_acqusition_source_cc1()
        self.set_frame_tirgger()
        self.set_frame_trigger_source()
        self.set_frame_count(1)

    def assert_cc1(self, value : bool)->None:
        """
        Assert CC1

        Args:
            value (bool): True or False
        
        Returns:
            None

        """
        if value:
            self.tcp.write("#CC1#1#")
        else:
            self.tcp.write("#CC1#0#")
        a = self.tcp.read()
        print(a)

if __name__ == "__main__":
    zcu104 = ZCU104(IPAddress = '192.168.1.10', TCPPort = 7)
    zcu104.connect()
    zcu104.camera_init()
    zcu104.disconnect()