# Intro into using lists.
# Lists are ordered sequences of items
# ["1","2","3"]

# Base Lists
string_list = ['soap', 'dog food', 'pens']
newRange = list(range(25))
string1 = "Grouper"

# Adding
string_list += ["cat food", "Grapes"]
string_list.extend([100, "Advil"])
string_list.insert(0, "Speakers")
string_list.insert(3, string1)

# Removing
string_list.pop(7)
string_list.remove("Speakers")

print(string_list)

# Finding things
index1 = string_list.index("soap")
print(index1)


# Sorting
print(sorted(string_list))
print(newRange)


# Joining
# use to join characters with items in a list
char1 = '* '
joined_list = char1.join(string_list)

print(joined_list)


# Unpacking lists
a, b, c, d, e, f, g = string_list

print(a, b, c)
