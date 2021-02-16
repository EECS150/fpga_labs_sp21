import numpy as np
from matplotlib.image import imread

img_np = imread('ucb_wheeler_hall.jpg')
height, width, _ = img_np.shape

for y in range(height):
  for x in range(width):
    r = float(img_np[y][x][0] / 255)
    g = float(img_np[y][x][1] / 255)
    b = float(img_np[y][x][2] / 255)

    gs = 0.2989 * r + 0.5870 * g + 0.1140 * b
    gs = int(gs * 255)
    print(np.binary_repr(gs, 8))
