# EZPZ Loops

sum = 0

user = {
    'Name': 1,
    'Score': 2,
    'Level': 1
}

for attribute in user.items():
    print(attribute)


print()
# Little coding challenge. Create a list from 1..10.
# using looping, find the sum total of the list.

number_list = list(range(1, 11))
list_count = len(number_list)

for i in number_list:
    sum += i

print(number_list)

print(f"Total items in list: {list_count}")

print(f"Total sum of numbers: {sum}")
