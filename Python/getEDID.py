# -*- coding: utf-8 -*-
"""
Created on Sun May 26 19:11:46 2024

@author: alexi
"""

import wmi
import binascii

def get_edid():
    w = wmi.WMI(namespace='root\\wmi')
    monitors = w.WmiMonitorDescriptorMethods()
    edid_list = []
    for monitor in monitors:
        edid = monitor.WmiGetMonitorRawEEdidV1Block(0)
        edid_list.append(edid[0])
        for i in range(len(edid[0])):
            print(f"{i} : {bin(edid[0][i])[2:].zfill(8)}")
    return edid_list

edid_info = get_edid()