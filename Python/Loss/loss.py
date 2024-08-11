# -*- coding: utf-8 -*-
"""
Created on Sun Jul 28 19:51:45 2024

@author: alexi
"""
import numpy as np

if __name__ == "__main__":
    beta : float = 0.001
    for p in range(256):
        p_ = p + 1
        S = beta * np.log(p_) * p_
        print(S)
    print(np.log2(0.001))