import matplotlib.pyplot as plt
import numpy as np 
from mpl_toolkits.mplot3d import Axes3D
from concurrent.futures import ThreadPoolExecutor
import math

from utils import integral, funcs

wm = 1 # sin wave's frequency
m = 3 # f_c = m f_m, m in n
wc = m * wm # triangular wave's frequency 

ac = 1 # sin wave's amplitude
mf = 0.3 # ac = mf am, mf < 1
am = mf * ac 

pwm = lambda t: funcs.pwm(t, wc, wm, ac, am)
f = lambda x, y: funcs.f(x, y, wc, wm, ac, am)
sin = np.sin
cos = np.cos

# mode: 0 -> a_mn, 1 -> b_mn, 2 -> c_mn, 3 -> d_mn
def get_inner_coeff(m, n, mode):
    if mode == 0:
        # a_mn
        if m == 0 and n == 0:
            return integral.partial_integral(0, 2*np.pi, f)
        elif m == 0:
            return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*cos(n*y))
        elif n == 0:
            return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*cos(m*x))
        else:
            return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*cos(m*x)*cos(n*y))

    elif mode == 1:
        # b_mn
        if m == 0 and n == 0:
            return 0
        elif m == 0:
            return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*sin(n*y))
        elif n == 0:
            return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*sin(m*x))
        else:
            return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*sin(m*x)*sin(n*y))

    elif mode == 2:
        # c_mn
        if m == 0 or n == 0: return 0
        return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*cos(m*x)*sin(n*y))

    elif mode == 3:
        # d_mn
        if m == 0 or n == 0: return 0
        return integral.partial_integral(0, 2*np.pi, lambda x, y: f(x, y)*sin(m*x)*cos(n*y))

h = 0.01
N = 10
t = np.arange(0, 4*np.pi + h, h)
x = t*wc
y = t*wm

inner_coeff = [get_inner_coeff(10, 10, 1)(_y) for _y in y]

plt.plot(y, inner_coeff)
plt.show()
