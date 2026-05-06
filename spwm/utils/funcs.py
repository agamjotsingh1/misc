import numpy as np

def carrier(a, w, t):  # Triangular carrier wave
    # a: amplitude, w: angular frequency, t: time
    return a - (2 * a / np.pi) * np.arccos(np.cos(w * t - (np.pi / 2)))

def modulating(a, w, t):  # Sine wave modulating signal
    # a: amplitude, w: angular frequency, t: time
    return a * np.sin(w * t)

def pwm(t, wc, wm, ac, am):  # PWM signal generation
    # t: time, wc/wm: angular freq of carrier/modulator
    # ac/am: amplitude of carrier/modulator
    return 1 if carrier(ac, wc, t) > modulating(am, wm, t) else 0

def f(x, y, wc, wm, ac, am):  # 2D function for PWM signal (used in integration)
    # x, y: sample positions (e.g., time along two axes)
    return 1 if carrier(ac, wc, x / wc) > modulating(am, wm, y / wm) else 0

