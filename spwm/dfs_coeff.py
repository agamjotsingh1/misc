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

# mode: 0 -> a_mn, 1 -> b_mn, 2 -> c_mn, 3 -> d_mn
def get_coeff(m, n, mode):
    sin = np.sin
    cos = np.cos

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

def dfs_coeff(N):
    a_coeff_matrix = np.zeros((N, N))
    b_coeff_matrix = np.zeros((N, N))
    c_coeff_matrix = np.zeros((N, N))
    d_coeff_matrix = np.zeros((N, N))

    for i in range(N):
        for j in range(N):
            a_coeff_matrix[i][j] = get_coeff(i, j, 0)
            b_coeff_matrix[i][j] = get_coeff(i, j, 1)
            c_coeff_matrix[i][j] = get_coeff(i, j, 2)
            d_coeff_matrix[i][j] = get_coeff(i, j, 3)


    coeff_matrix = [a_coeff_matrix, b_coeff_matrix, c_coeff_matrix, d_coeff_matrix]
    return coeff_matrix

def dfs_coeff_multithreaded(M, N, num_threads=16):
    a_coeff_matrix = np.zeros((M, N))
    b_coeff_matrix = np.zeros((M, N))
    c_coeff_matrix = np.zeros((M, N))
    d_coeff_matrix = np.zeros((M, N))

    def compute_chunk(matrix, mode, start_i, end_i):
        for i in range(start_i, end_i):
            for j in range(N):
                matrix[i][j] = get_coeff(i, j, mode)

    chunk_size = math.ceil(M / 4)  # Divide each matrix into 4 chunks
    
    tasks = []
    for mode in range(4):  # 0: a, 1: b, 2: c, 3: d
        matrix = [a_coeff_matrix, b_coeff_matrix, c_coeff_matrix, d_coeff_matrix][mode]
        for chunk in range(4):
            start_i = chunk * chunk_size
            end_i = min((chunk + 1) * chunk_size, M)
            tasks.append((matrix, mode, start_i, end_i))

    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        executor.map(lambda args: compute_chunk(*args), tasks)

    return a_coeff_matrix, b_coeff_matrix, c_coeff_matrix, d_coeff_matrix

h = 0.01
N = 10
t = np.arange(0, np.pi + h, h)
x = t*wc
y = t*wm
coeff = dfs_coeff_multithreaded(N, N)
a_coeff_matrix, b_coeff_matrix, c_coeff_matrix, d_coeff_matrix = coeff

print("A: \n", a_coeff_matrix)
print("B: \n", b_coeff_matrix)
print("C: \n", c_coeff_matrix)
print("D: \n", d_coeff_matrix)

with open("data/fourier_coefficients.txt", "w") as f:
    f.write("a_coeff_matrix:\n")
    np.savetxt(f, a_coeff_matrix, fmt="%.5f")
    f.write("\n\nb_coeff_matrix:\n")
    np.savetxt(f, b_coeff_matrix, fmt="%.5f")
    f.write("\n\nc_coeff_matrix:\n")
    np.savetxt(f, c_coeff_matrix, fmt="%.5f")
    f.write("\n\nd_coeff_matrix:\n")
    np.savetxt(f, d_coeff_matrix, fmt="%.5f")

''' PLOTTING '''
'''
# Create the grid for c and d
a = np.arange(0, N)
b = np.arange(0, N)
c = np.arange(0, N)
d = np.arange(0, N)
C, D = np.meshgrid(c, d)

# Flatten the matrices for use in the plot
C_flat = C.flatten()
D_flat = D.flatten()
a_coeff_flat = a_coeff_matrix.flatten()

# Create the 3D plot
fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection='3d')

# Create a 3D stem plot
#ax.stem(C_flat, D_flat, a_coeff_flat, basefmt=" ", linefmt="b-", markerfmt="bo")

# Set labels and title
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('b_mn coeffecients')
ax.set_title('b_mn coeffecients')

# Show the plot
plt.show()
'''
