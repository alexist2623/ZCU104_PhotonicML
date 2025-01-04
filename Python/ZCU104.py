# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 18:01:13 2023

@author: QC109_4
"""
import TCPClient_v1_00 as TCP
import time

class ZCU104:
    def __init__(self, IPAddress = '172.22.22.236', TCPPort = 7):    
        self.tcp = TCP.TCP_Client(IPAddress = IPAddress, TCPPort = 7)

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
        print("byte send")
        # self.read_uart()

    def set_acquisition_trigger(self)->None:
        """
        Set acquisition as a hardware trigger mode

        Args:
            None
        
        Returns:
            None

        """
        self.send_uart(
            addr = 0x00040100 | 0x04,
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )
        
    def set_no_acquisition_trigger(self)->None:
        """
        Set acquisition as a hardware trigger mode

        Args:
            None
        
        Returns:
            None

        """
        self.send_uart(
            addr = 0x00040100 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
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
            addr = 0x00040140 | 0x04,
            addr_len = 0b11,
            data = [0x09, 0x00, 0x00, 0x00]
        )
        
    def set_acqusition_source_soft(self)->None:
        """
        Set acquisition source as CC1

        Args:
            None
        
        Returns:
            None

        """
        self.send_uart(
            addr = 0x00040140 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_frame_count(self, frame_count : int)->None:
        """
        Set frame count
        """
        data_bytes = [
            frame_count & 0xFF,
            (frame_count >> 8) & 0xFF,
            (frame_count >> 16) & 0xFF,
            (frame_count >> 24) & 0xFF
        ]
        self.send_uart(
            addr = 0x000400A0 | 0x04,  # == 0x000400A4
            addr_len = 0b11,
            data = data_bytes
        )

    def set_frame_tirgger(self)->None:
        """
        Set framer start as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040200 | 0x04,
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )

    def set_no_frame_tirgger(self)->None:
        """
        Set framer start as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040200 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_frame_trigger_source_cc2(self)->None:
        """
        Set frame trigger source as CC2
        """
        self.send_uart(
            addr = 0x00040240 | 0x04,
            addr_len = 0b11,
            data = [0x0A, 0x00, 0x00, 0x00]
        )

    def set_frame_trigger_source_soft(self)->None:
        """
        Set frame trigger source as CC2
        """
        self.send_uart(
            addr = 0x00040240 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_tap_1x3(self)->None:
        """
        Set cameralink tap configuartion as 1X3-1Y
        """
        self.send_uart(
            addr = 0x0720 | 0x04,
            addr_len = 0b01,
            data = [0x07, 0x00, 0x00, 0x00]
        )

    def cl_clock(self)->None:
        """
        Set cameralink clock to 82MHz
        """
        self.send_uart(
            addr = 0x0740 | 0x04,
            addr_len = 0b01,
            data = [0x17, 0x00, 0x00, 0x00]
        )

    def set_pixel_format(self)->None:
        """
        Set pixel format to mono8
        """
        self.send_uart(
            addr = 0x00030020 | 0x04,
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )
        
    def make_soft_acq(self):
        self.send_uart(
            addr = (0x00040120 | 0x04),
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )
        
    def make_soft_frame(self):
        self.send_uart(
            addr = (0x00040220 | 0x04),
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )

    def camera_init(self)->None:
        """
        Initialize camera
        """
        self.reset_dram()
        self.reset_clink()
        self.set_tap_1x3()
        self.set_pixel_format()
        self.cl_clock()
        self.set_acquisition_trigger()
        self.set_acqusition_source_cc1()
        self.set_frame_tirgger()
        self.set_frame_trigger_source_cc2()
        self.set_frame_count(1)
        
    def camera_soft_init(self)->None:
        """
        Initialize camera
        """
        self.set_tap_1x3()
        self.set_pixel_format()
        self.cl_clock()
        self.set_acquisition_trigger()
        self.set_acqusition_source_soft()
        self.set_frame_tirgger()
        self.set_frame_trigger_source_soft()
        self.set_frame_count(1)
        self.make_soft_frame()
        self.make_soft_acq()

    def cc_ctrl(self, cc_channel: int, cc_value: bool)->None:
        """
        Control CC channel
        """
        packet = f"#CC_CTRL#{(int(cc_value) & 0xff) << 8 | (cc_channel & 0xff)}#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
    
    def read_dram(self, addr: int, size: int)->bytes:
        """
        Read DRAM data

        addr : start address to read with offset of XPAR_MIG_0_BASEADDR 0x400000000
        size : number of 128-bit chunks to read
        """
        packet = f"#READ_DRAM#{addr}#{size}#!EOL#"
        self.tcp.write(packet)
        a = b""
        while len(a) != 2048:
            a += self.tcp.socket.recv(2048)
        print(len(a))
        if not hasattr(self, 'img_data'):
            self.img_data = b""  # img_data 초기화
        self.img_data += a
        
    def write_dram(self, addr: int, data_upper, data_lower):
        packet = f"#WRITE_DRAM#{addr}#{data_upper}#{data_lower}#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
    
    def reset_dram(self):
        packet = "#RESET_DRAM#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
        time.sleep(3)
    
    def reset_clink(self):
        packet = "#RESET_CLINK#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
        time.sleep(3)
        
    def read_uart_valid(self):
        packet = "#READ_UART_VAL#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
        
    def read_uart(self):
        packet = "#READ_UART_DATA#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
    
    def read_img_num(self):
        packet = "#READ_IMG_NUM#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)
        
    
    def auto_start(self):
        packet = "#AUTO_START#!EOL#"
        self.tcp.write(packet)
        a = self.tcp.read()
        print(a)

if __name__ == "__main__":
    zcu104 = ZCU104(IPAddress = '172.22.22.236', TCPPort = 7)
    zcu104.connect()
    zcu104.camera_init()
    zcu104.auto_start()
    time.sleep(1)
    zcu104.cc_ctrl(0b0001,1)
    time.sleep(1)
    zcu104.cc_ctrl(0b0010,1)
    time.sleep(5)
    for i in range(1122):
        zcu104.read_dram(0x00000000, i)
    print(len(zcu104.img_data))
    zcu104.read_img_num()
    zcu104.disconnect()
    with open("img_data.bin", "wb") as f:
        f.write(zcu104.img_data)
    
    
