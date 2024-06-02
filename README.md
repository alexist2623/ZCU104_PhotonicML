# FPGA Development for CRDONN
## Overview
<p align="center">
<img width="800" alt="image" src="https://github.com/alexist2623/ZCU104_PhotonicML/assets/49219392/7b38fc93-df9c-44e0-bf9d-37d0aac752fb">
</p>

This project is composed of verilog codes and python codes which sends image data to SLM for Complex-valued, Reconfigurable,Diffractive all-Optical Neural Networks(CRDONN). The existing CRDONN system updated data from the PC. However, this method had difficulty updating data at precise timings due to the influence of the OS, which acted as a significant bottleneck in increasing the overall system bandwidth. For example, the existing image update consumed about 1 frame per second. To eliminate this bottleneck, an image update method using FPGA has been devised, and a performance improvement of approximately 10 frames per second is expected.

## Image data to SLM device
<p align="center">
<img width="800" alt="image" src="https://github.com/alexist2623/ZCU104_PhotonicML/assets/49219392/0cbd90f3-2823-4578-bb52-35779e93b512">
</p>

Image data is saved in SD card as a ```bin``` file. This image is read from CPU(PS) and sent to PL side which converts image data to HDMI data format(8b/10b conversion). The image data is fixed at a resolution of 100x100, with the rest of the area being zero-padded on the PL side. Additionally, the image data is transformed on the PL side to comply with the HDMI 1.4 standard, and the auxiliary data for HDMI is fully input according to the EDID information of the SLM. Currently, the system works on a regular display, but the image is not displaying correctly on the SLM, and we are in the process of debugging this issue. HDMI Controller code is modified from https://github.com/sameer 's HDMI Code (https://github.com/hdl-util/hdmi.git).

## PL-PS Cooperation
<p align="center">
<img width="800" alt="image" src="https://github.com/alexist2623/ZCU104_PhotonicML/assets/49219392/af6d48fe-7562-43f3-a437-d3fc0143e98f">
</p>

The image data is input into two separate FIFOs. One FIFO receives the new image data, while the other stores previously used data to be reused if no new image is available. When a signal indicating the need to input a new image from an external source is received (e.g., the camera exposure is complete), an interrupt signal is sent from the PL to the PS. The PS then sends the new image to the PL. This interrupt is handled by the GIC v2, and a service routine is defined in the PS firmware to process these interrupts.

