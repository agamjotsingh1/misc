import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import soundfile as sf

def interpolate(signal):
    interpolated_signal = np.zeros(2*len(signal))
    for i in range(len(signal)):
        interpolated_signal[2*i] = signal[i]
        if(i < len(signal) - 1): interpolated_signal[2*i + 1] = (signal[i + 1] + signal[i])/2
    return interpolated_signal

signal, rate = sf.read('/home/agam/Garbage/audioshit/music.wav')

sf.write(f"/home/agam/Garbage/audioshit/music_interpol.wav", interpolate(signal), rate)
