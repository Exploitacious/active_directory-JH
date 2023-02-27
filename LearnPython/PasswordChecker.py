# Simplest form of a Password Checking Program

username = str(input("\n Please enter your username \n"))
existing_Pass = str("securePassword")
correct_Pass = False  # Reset the correct_Pass bool

# Stupid coding challenge question response. Hide Password and calculate length
pass_char_len = len(existing_Pass)
hidden_Pass = pass_char_len * '*'


# Print response to terminal
print(
    f'\n Your username is {username} and your password {hidden_Pass}, is {pass_char_len} characters long\n')

# Enter Password Input
entered_Pass = str(input("\n Please enter your password\n"))

# Check the password against the real one, return result True or False
correct_Pass = (existing_Pass == entered_Pass)

if (correct_Pass == True):
    print("Correct!")
else:
    print("Incorrect, please try again.")
