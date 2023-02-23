# This is a simple program meant to tell you how old you are in years based on the year you were born.

# Constant Variable
today = 2023

# Input data from user and enforce int
year_guess = int(input("What year were you born?\n"))

# Calculate
answer = today - year_guess

# Return result
print(f'You are {answer} years old!')
