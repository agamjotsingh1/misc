import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file
df = pd.read_csv("pollutant.csv")

# Convert pollutant_avg to numeric and remove NA values
df["pollutant_avg"] = pd.to_numeric(df["pollutant_avg"], errors="coerce")
df = df.dropna(subset=["pollutant_avg"])

# Count frequency of each pollutant type
pollutant_counts = df["pollutant_id"].value_counts()

# Plot pie chart
plt.figure(figsize=(6, 6))
plt.pie(
    pollutant_counts,
    labels=pollutant_counts.index,
    autopct="%1.1f%%",
    startangle=90
)
plt.title("Distribution of Pollutant Types")
plt.axis("equal")  # Ensures pie is circular
plt.show()
