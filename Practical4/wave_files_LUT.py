import numpy as np
import matplotlib.pyplot as plt
import scipy.io.wavfile as wav

def generate_lut(wav_file, lut_size=10000):
    sample_rate, data = wav.read(wav_file)

    # If stereo, take one channel
    if len(data.shape) > 1:
        data = data[:, 0]

    # Normalize from [-1, 1] to [0, 4095]
    data = data / np.max(np.abs(data))  # Normalize to [-1, 1]
    data = (data + 1) / 2 * 400         # Now in [0, 4095]
    data = np.clip(data, 0, 400)

    # Downsample to LUT size
    indices = np.linspace(0, len(data) - 1, lut_size).astype(int)
    lut = data[indices].astype(int)

    return lut

def plot_lut(lut, title):
    plt.figure()
    plt.plot(lut, marker='o')
    plt.title(title)
    plt.xlabel("Sample")
    plt.ylabel("Amplitude (12-bit)")
    plt.grid(True)
    plt.show()

def format_c_array(lut, name):
    c_array = f"const uint16_t {name}[{len(lut)}] = {{\n    "
    c_array += ', '.join(map(str, lut))
    c_array += "\n};"
    return c_array

# Example usage (once you have your files)
wav_files = ["drum.wav", "guitar.wav", "piano.wav"]
for i, file in enumerate(wav_files):
    lut = generate_lut(file)
    plot_lut(lut, f"Waveform {i+1}")
    print(format_c_array(lut, f"waveform{i+1}_lut"))
