import matplotlib.pyplot as plt
import numpy as np 
from mpl_toolkits.mplot3d import Axes3D
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
def get_coeff(m, n, mode):

    if mode == 0:
        # a_mn
        if m == 0 and n == 0:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, f)/((2*np.pi)**2)
        elif m == 0:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*cos(n*y))/((2*np.pi)**2) * 2
        elif n == 0:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*cos(m*x))/((2*np.pi)**2) * 2
        else:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*cos(m*x)*cos(n*y))/((2*np.pi)**2) * 4

    elif mode == 1:
        # b_mn
        if m == 0 and n == 0:
            return 0
        elif m == 0:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*sin(n*y))/((2*np.pi)**2) * 2
        elif n == 0:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*sin(m*x))/((2*np.pi)**2) * 2
        else:
            return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*sin(m*x)*sin(n*y))/((2*np.pi)**2) * 4

    elif mode == 2:
        # c_mn
        if m == 0 or n == 0: return 0
        return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*cos(m*x)*sin(n*y))/((2*np.pi)**2) * 4

    elif mode == 3:
        # d_mn
        if m == 0 or n == 0: return 0
        return integral.double_integral(0, 2*np.pi, 0, 2*np.pi, lambda x, y: f(x, y)*sin(m*x)*cos(n*y))/((2*np.pi)**2) * 4

def dfs_coeff(M, N):
    a_coeff_matrix = np.zeros((M, N))
    b_coeff_matrix = np.zeros((M, N))
    c_coeff_matrix = np.zeros((M, N))
    d_coeff_matrix = np.zeros((M, N))

    for i in range(M):
        for j in range(N):
            a_coeff_matrix[i][j] = get_coeff(i, j, 0)
            b_coeff_matrix[i][j] = get_coeff(i, j, 1)
            c_coeff_matrix[i][j] = get_coeff(i, j, 2)
            d_coeff_matrix[i][j] = get_coeff(i, j, 3)

    return a_coeff_matrix, b_coeff_matrix, c_coeff_matrix, d_coeff_matrix

def reconstruct_f(x, y, M, N, ceoff):
    """
    Reconstruct the function f(x,y) using the 2D Fourier series
    M, N: Number of terms to include in the reconstruction
    """
    # Calculate L1 and L2 (periods in x and y directions)
    L1 = 2*np.pi
    L2 = 2*np.pi

    # Initialize the reconstruction with a00 term
    a00 = coeff[0][0][0]
    result = a00

    # First sum: a0n terms
    for n in range(1, N):
        a0n = coeff[0][0][n]
        result += a0n * np.cos(2*np.pi*n*y/L2)

    # Second sum: am0 terms
    for m in range(1, M):
        am0 = coeff[0][0][m]
        result += am0 * np.cos(2*np.pi*m*x/L1)

    # Third sum: b0n terms
    for n in range(1, N):
        b0n = coeff[1][0][n]
        result += b0n * np.sin(2*np.pi*n*y/L2)

    # Fourth sum: bm0 terms
    for m in range(1, M):
        bm0 = coeff[1][m][0]
        result += bm0 * np.sin(2*np.pi*m*x/L1)

    # Fifth sum: cmn terms
    for n in range(1, N):
        for m in range(1, M):
            cmn = coeff[2][m][n]
            result += cmn * np.cos(2*np.pi*m*x/L1) * np.sin(2*np.pi*n*y/L2)

    # Sixth sum: dmn terms
    for n in range(1, N):
        for m in range(1, M):
            dmn = ceoff[3][m][n]
            result += dmn * np.sin(2*np.pi*m*x/L1) * np.cos(2*np.pi*n*y/L2)

    # Seventh sum: amn terms
    for n in range(1, N):
        for m in range(1, M):
            amn = coeff[0][m][n]
            result += amn * np.cos(2*np.pi*m*x/L1) * np.cos(2*np.pi*n*y/L2)

    # Eighth sum: bmn terms
    for n in range(1, N):
        for m in range(1, M):
            bmn = coeff[1][m][n]
            result += bmn * np.sin(2*np.pi*m*x/L1) * np.sin(2*np.pi*n*y/L2)

    return result

h = 0.01
M = N = 50
t = np.linspace(0, 1*np.pi, int(1*np.pi/h))
x = t*wc
y = t*wm

coeff = dfs_coeff_multithreaded_fast(M, N)

out = [pwm(_) for _ in t]
out_re = [reconstruct_f(wc*_t, wm*_t, M, N, coeff) for _t in t]

plt.figure()
plt.plot(t, out, label = 'PWM output')
plt.plot(t, out_re, label = 'PWM reconstruction output')
plt.legend()
plt.show()
