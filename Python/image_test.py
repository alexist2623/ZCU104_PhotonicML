import numpy as np
from PIL import Image

# 명확한 흑백 패턴 데이터 생성
image_array = np.array([
    [0, 255, 0, 255],
    [255, 0, 255, 0],
    [0, 255, 0, 255],
    [255, 0, 255, 0]
], dtype=np.uint8)

# 이미지를 생성
image = Image.fromarray(image_array, mode='L')

# 이미지 확인
image.show()