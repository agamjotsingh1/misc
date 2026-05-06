import matplotlib.pyplot as plt
import numpy as np

# ----------------------------------------
# Replace with your actual cycle values
# ----------------------------------------
data = {
    "Bubble Sort": {"Dynamic": 181, "Static1": 251, "Static0": 409},
    "Fibonacci Branching": {"Dynamic": 1643, "Static1": 2017, "Static0": 1643},
    "Ramp-up Branching": {"Dynamic": 425, "Static1": 4289, "Static0": 3621},
    "Collatz Conjecture": {"Dynamic": 1797, "Static1": 2035, "Static0": 1873},
}

programs = list(data.keys())
dynamic = [data[p]["Dynamic"] for p in programs]
static  = [data[p]["Static1"] for p in programs]
none    = [data[p]["Static0"] for p in programs]

x = np.arange(len(programs))

# Settings
bar_width = 0.2
bar_spacing = 0.09  # extra gap between bars

plt.figure(figsize=(11, 6))

# Plot bars with gaps + slight transparency
plt.bar(x - bar_width - bar_spacing, none, bar_width, alpha=0.7,
        label="Static Prediction 0")

plt.bar(x, static, bar_width, alpha=0.7,
        label="Static Prediction 1")

plt.bar(x + bar_width + bar_spacing, dynamic, bar_width, alpha=0.7,
        label="Dynamic Prediction")

# Labels & style
plt.xticks(x, programs)
plt.ylabel("Number of Cycles")
plt.xlabel("Programs/Delta patterns")
plt.title("Branch Prediction Comparison")
plt.legend()
plt.grid(axis='y', linestyle='--', alpha=0.5)

plt.tight_layout()

plt.savefig("./branch_prediction_stats.png")
plt.show()