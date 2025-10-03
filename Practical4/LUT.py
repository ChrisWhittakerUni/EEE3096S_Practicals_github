import numpy as np
import matplotlib.pyplot as plt

# Constants
samples = 10000
max_val = 400  # 12-bit resolution
mid_val = max_val // 2

# Generate LUTs
x = np.linspace(0, 1, samples, endpoint=False)

# Sinusoidal wave
sine_lut = (mid_val + mid_val * np.sin(2 * np.pi * x)).astype(int)

# Sawtooth wave
saw_lut = (x * max_val).astype(int)

# Triangle wave
tri_lut = (2 * x * max_val).astype(int)
tri_lut[x > 0.5] = (2 * (1 - x[x > 0.5]) * max_val).astype(int)

# Plotting
plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.plot(sine_lut)
plt.title("Sine Wave")

plt.subplot(1, 3, 2)
plt.plot(saw_lut)
plt.title("Sawtooth Wave")

plt.subplot(1, 3, 3)
plt.plot(tri_lut)
plt.title("Triangle Wave")

plt.tight_layout()
plt.show()


def print_c_array(name, data):
    print(f"uint16_t {name}[{samples}] = {{", end="")
    print(", ".join(str(v) for v in data), end="")
    print("};\n")

print_c_array("sine_lut", sine_lut)
print_c_array("saw_lut", saw_lut)
print_c_array("tri_lut", tri_lut)
