import numpy as np

text = "\n\rEECS 151/251A, Spring 2021\n\rIntroduction to Digital Design and Integrated Circuits\n\rHello from PYNQ-Z1!"
ascii_code = [print(np.base_repr(ord(c), base=16)) for c in text]
