"""
Profiling script for airline dimension dataset.

Purpose:
- inspect schema structure
- validate candidate business key uniqueness
- identify null values
- assess suitability for warehouse dimension modeling
"""

import pandas as pd

df = pd.read_csv("data/raw/airlines.csv")


def print_section(title):
    print(f"\n=== {title} ===")


print_section("HEAD")
print(df.head())

print_section("SHAPE")
print(df.shape)

print_section("COLUMNS")
print(df.columns)

print_section("DTYPES")
print(df.dtypes)

# assess source data completeness
print_section("NULL ANALYSIS")
print(df.isnull().sum())

# validate candidate business keys
print_section("UNIQUENESS VALIDATION")
print("Unique IATA codes:", df["IATA_CODE"].nunique())
print("Duplicate IATA codes:", df["IATA_CODE"].duplicated().sum())
