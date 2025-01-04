import re
import numpy as np
from PIL import Image

# Function to convert lines of hex data to an image
def hex_to_image(byte_data):
    # Convert each line into an array of bytes and stack without padding
    images = []
    img_width = 66*32

    byte_array = list(byte_data)  # Byte data를 리스트로 변환

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

# Main program
if __name__ == "__main__":
    # Input data
    hex_data = 0
    with open("img_data.bin", "rb") as f:
        hex_data = f.read()
    # Process the data
    print(len(hex_data))
    image = hex_to_image(hex_data)

    # Save the image
    image.save("output_image.png")
    print("Image saved as 'output_image.png'")
