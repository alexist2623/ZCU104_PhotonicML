# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 18:01:13 2023

@author: QC109_4
"""
import TCPClient_v1_00 as TCP
import time
import re
import numpy as np
from PIL import Image

class ZCU104:
    def __init__(self, IPAddress = "172.22.22.236", TCPPort = 7):
        self.tcp = TCP.TCP_Client(IPAddress = IPAddress, TCPPort = TCPPort)

    def connect(self):
        self.tcp.connect()
        print("RFSoC is connected with TCP...")     

    def disconnect(self):
        self.tcp.disconnect()

    def start_display(self):
        """START DISPLAY"""
        self.tcp.write("#START_DISPLAY#")
        a = self.tcp.read()
        print(a)

    def stop_display(self):
        """STOP DISPLAY"""
        self.tcp.write("#STOP_DISPLAY#")
        a = self.tcp.read()
        print(a)

    def load_sd_card(self):
        """LOAD SD CARD"""
        self.tcp.write("#LOAD_SD_CARD#")
        a = self.tcp.read()
        print(a)

    def set_new_image(self):
        """SET NEW IMAGE"""
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
        ):
        """SET NEW IMAGE"""
        self.tcp.write(
            f"#SET_TEST#{test_mode}#{test_data}#{start_X}#"
            f"{start_Y}#{end_X}#{end_Y}#"
        )
        a = self.tcp.read()
        print(a)

    def set_camera_exposure_start(
            self,
            input_polarity : int,
            output_polarity : int,
            timer : int,
            event : int,
            delay : int
        ):
        self.tcp.write(
            f"#SET_CAM_EXP_START#{input_polarity}#"
            f"{output_polarity}#{timer}#{event}#{delay}#"
        )
        a = self.tcp.read()
        print(a)

    def set_camera_exposure_end(
            self,
            input_polarity : int,
            output_polarity : int,
            timer : int,
            event : int,
            delay : int
        ):
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
        ):
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

    def set_acquisition_trigger(self):
        """
        Set acquisition as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040100 | 0x04,
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )
        
    def set_no_acquisition_trigger(self):
        """
        Set acquisition as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040100 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_acqusition_source_cc1(self):
        """
        Set acquisition source as CC1
        """
        self.send_uart(
            addr = 0x00040140 | 0x04,
            addr_len = 0b11,
            data = [0x09, 0x00, 0x00, 0x00]
        )
        
    def set_acqusition_source_soft(self):
        """
        Set acquisition source as CC1
        """
        self.send_uart(
            addr = 0x00040140 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_frame_count(self, frame_count : int):
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

    def set_frame_tirgger(self):
        """
        Set framer start as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040200 | 0x04,
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )

    def set_no_frame_tirgger(self):
        """
        Set framer start as a hardware trigger mode
        """
        self.send_uart(
            addr = 0x00040200 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_frame_trigger_source_cc2(self):
        """
        Set frame trigger source as CC2
        """
        self.send_uart(
            addr = 0x00040240 | 0x04,
            addr_len = 0b11,
            data = [0x0A, 0x00, 0x00, 0x00]
        )

    def set_frame_trigger_source_soft(self):
        """
        Set frame trigger source as CC2
        """
        self.send_uart(
            addr = 0x00040240 | 0x04,
            addr_len = 0b11,
            data = [0x00, 0x00, 0x00, 0x00]
        )

    def set_tap_1x3(self):
        """
        Set cameralink tap configuartion as 1X3-1Y
        """
        self.send_uart(
            addr = 0x0720 | 0x04,
            addr_len = 0b01,
            data = [0x07, 0x00, 0x00, 0x00]
        )

    def cl_clock(self):
        """
        Set cameralink clock to 82MHz
        """
        self.send_uart(
            addr = 0x0740 | 0x04,
            addr_len = 0b01,
            data = [0x17, 0x00, 0x00, 0x00]
        )

    def set_pixel_format(self):
        """
        Set pixel format to mono8
        """
        self.send_uart(
            addr = 0x00030020 | 0x04,
            addr_len = 0b11,
            data = [0x01, 0x00, 0x00, 0x00]
        )

    def camera_init(self):
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

    def cc_ctrl(self, cc_channel: int, cc_value: bool):
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

        Args:
            addr : start address to read with offset of XPAR_MIG_0_BASEADDR 0x400000000
            size : number of 128-bit chunks to read
        """
        packet = f"#READ_DRAM#{addr}#{size}#!EOL#"
        self.tcp.write(packet)
        a = b""
        while len(a) != 2048:
            a += self.tcp.socket.recv(2048)
        if not hasattr(self, "img_data"):
            self.img_data = b""  # img_data 초기화
        self.img_data += a

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

def hex_to_image(byte_data):
    images = []
    img_width = 66*32

    byte_array = list(byte_data)

    for i in range(0, len(byte_array), img_width):
        chunk = byte_array[i:i + img_width]
        
        # Ensure each chunk is exactly 2048 bytes (pad with 0 if necessary)
        if len(chunk) < img_width:
            chunk.extend([0] * (img_width - len(chunk)))
        
        # Convert chunk to numpy array
        line_array = np.array(chunk, dtype=np.uint8).reshape(1, -1)  # Reshape as a single row
        images.append(line_array)

    # Concatenate all line arrays vertically
    image_array = np.vstack(images)

    # Convert to image
    image = Image.fromarray(image_array, mode='L')
    return image

ms = 1E-3

if __name__ == "__main__":
    zcu104 = ZCU104(IPAddress = "172.22.22.236", TCPPort = 7)
    zcu104.connect()
    zcu104.camera_init()
    zcu104.auto_start()
    time.sleep(1)
    read_num = 10
    read_addr_offset = int(1122 * 2048 * (read_num-1))
    for i in range(10):
        zcu104.cc_ctrl(0b0001,1)
        zcu104.cc_ctrl(0b0010,1)
        time.sleep(16.67 * ms)
    time.sleep(5)
    
    zcu104.img_data = b""
    for i in range(1122):
        print(f"{i} th read")
        zcu104.read_dram(0x00000000 | 0x0, i)
    
    image = hex_to_image(zcu104.img_data)
    image.save("output_image_0.png")
    print("Image saved as 'output_image.png'")
    
    read_addr_offset = int(1122 * 2048 * (read_num-2))
    zcu104.img_data = b""
    for i in range(1122):
        print(f"{i} th read")
        zcu104.read_dram(0x00000000 | read_addr_offset, i)
    
    image = hex_to_image(zcu104.img_data)
    image.save("output_image_8.png")
    print("Image saved as 'output_image.png'")
    
    read_addr_offset = int(1122 * 2048 * (read_num-1))
    zcu104.img_data = b""
    for i in range(1122):
        print(f"{i} th read")
        zcu104.read_dram(0x00000000 | read_addr_offset, i)
    
    image = hex_to_image(zcu104.img_data)
    image.save("output_image_9.png")
    print("Image saved as 'output_image.png'")
    
    read_addr_offset = int(1122 * 2048 * (read_num))
    zcu104.img_data = b""
    for i in range(1122):
        print(f"{i} th read")
        zcu104.read_dram(0x00000000 | read_addr_offset, i)
    
    image = hex_to_image(zcu104.img_data)
    image.save("output_image_10.png")
    print("Image saved as 'output_image.png'")

    zcu104.read_img_num()
    zcu104.disconnect()
    
    
    # zcu104 = ZCU104(IPAddress = "192.168.1.10", TCPPort = 7)
    # zcu104.connect()
    # zcu104.start_display()
    # start_time = time.time()
    # for i in range(3):
    #     time.sleep(1.00)
    #     zcu104.set_new_image()
    
    # zcu104.disconnect()
    
    # end_time = time.time()  # 종료 시간 기록
    
    # execution_time = end_time - start_time
    # print(execution_time)

