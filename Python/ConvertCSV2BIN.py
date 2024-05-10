# -*- coding: utf-8 -*-
"""
Created on Wed May  8 18:02:06 2024

@author: alexi
"""

import csv
import struct
from itertools import islice

def saveBinaryDataFromCSV(row_num, csv_file_path, output_folder):
    with open(csv_file_path, 'r', newline='') as file:
        reader = csv.reader(file)
        row = next(islice(reader, row_num, row_num + 1), None)
        row_number = row[0]
        binary_data = row[1:]
        # j = 0
        # for b in binary_data:
        #     if int(b) == 255:
        #         print(str(1)+' ', end = '')
        #     else:
        #         print(str(0)+' ', end = '')
        #     j += 1
        #     if( j%100 == 0 ):
        #         print()
        byte_array = bytearray(int(b) for b in binary_data)
        with open(f'{output_folder}/test{str(row_num).zfill(4)}.bin', 'wb') as bin_file:
            bin_file.write(byte_array)

if __name__ == "__main__":
    csv_file_path = 'MNIST_subset_1000_train.csv'
    output_folder = f'TEST_DATA'
    for row_num in range(1000):
        saveBinaryDataFromCSV(row_num, csv_file_path, output_folder)