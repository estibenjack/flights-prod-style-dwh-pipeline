"""
Profiling script for flight operations dataset.

Purpose:
- inspect schema structure
- assess source data completeness
- identify candidate dimensions and relationships
- analyze delay and cancellation metrics
- support warehouse fact table modeling
"""

import pandas as pd

df = pd.read_csv("data/raw/flights.csv", nrows=100)

# when loading the full dataset later:
# pd.read_csv("file_name.csv", low_memory=False)
#
# helps avoid mixed-type inference issues in large CSVs


def print_section(title):
    print(f"\n=== {title} ===")


print_section("HEAD")
print(df.head())

print_section("SHAPE")
print(df.shape)

print_section("COLUMNS")
print(df.columns)

print_section("DATA TYPES")
print(df.dtypes)

# assess source data completeness
print_section("NULL ANALYSIS")
print(df.isnull().sum().sort_values(ascending=False))

# validate candidate business keys
print_section("AIRLINE VALUES")
print(sorted(df["AIRLINE"].unique()))

print_section("ORIGIN AIRPORT COUNT")
print(df["ORIGIN_AIRPORT"].nunique())

print_section("DESTINATION AIRPORT COUNT")
print(df["DESTINATION_AIRPORT"].nunique())

print_section("CANCELLATION REASON BREAKDOWN")
print(df["CANCELLATION_REASON"].value_counts(dropna=False))

print_section("ARRIVAL DELAY DISTRIBUTION")
print(df["ARRIVAL_DELAY"].describe())

# understand the ratio of cancelled to non-cancelled flights in the dataset
print_section("CANCELLED BREAKDOWN")
print(df["CANCELLED"].value_counts(dropna=False))
