import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

def interpolate(signal):
    interpolated_signal = np.zeros(2*len(signal) - 1)
    for i in range(len(signal)):
        interpolated_signal[2*i] = signal[i]
        if(i < len(signal) - 1): interpolated_signal[2*i + 1] = int((signal[i + 1] + signal[i])/2)
    return interpolated_signal

def interpolate_img(img):
    # new_img = np.array([])
    # for i in range(len(img)):
    #     row = img[i]
    #     new_img = np.append(new_img, interpolate(row))
    #
    #     if(i < len(img) - 1):
    #         for j in range(len(row)):
    #             new_img = np.append(new_img, int((img[i][j] + img[i + 1][j])/2))
    #
    #             if j < len(row) - 1:
    #                 new_img = np.append(new_img, int((img[i][j + 1] + img[i + 1][j + 1] + img[i][j] + img[i + 1][j])/4))
    #
    # return np.reshape(new_img, (2*len(img) - 1, 2*len(img[0]) - 1))

    new_img = np.zeros((2*img.shape[0], 2*img.shape[1]))
    for i in range(len(img)):
        for j in range(len(img[i])):
            new_img[2*i][2*j] = img[i][j]

    for i in range(len(img)-1):
        for j in range(len(img[i])-1):
            new_img[2*i][2*j + 1] = int((new_img[2*i][2*j] + new_img[2*i][2*j + 2])/4)
            new_img[2*i + 1][2*j] = int((new_img[2*i][2*j] + new_img[2*i + 2][2*j])/4)
            new_img[2*i + 1][2*j + 1] = int((new_img[2*i][2*j] + new_img[2*i + 2][2*j + 2])/4)

    return new_img
 
img = mpimg.imread("../images/einstein.jpg")
print(len(img[:, :, 0]), len(img[:, :, 0][0]))
plt.imshow(interpolate_img(img[:, :, 0]), cmap="gray")
plt.show()
plt.imshow((img[:, :, 0]), cmap="gray")
plt.show()
