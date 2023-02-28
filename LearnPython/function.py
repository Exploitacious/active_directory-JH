# Functional coding challenge to find the highest Even number in a list
#

def highest_even(*args):
    '''
    This is just about the dumbest challenge yet, but a good test of abilities.
    When supplied with params with a potentially unlimited list of numbers, 
    find and extract the highest possible EVEN number in the list.

    Usage Example: highest_even([10,2,3,4,8,11])
    '''

    even_numbers = list([])

    # Select only the even numbers
    for n in args[0]:
        if n % 2 == 0:
            even_numbers += [n]

    # Select the highest even number
    even_numbers.sort(reverse=True)
    return even_numbers[0]


print(highest_even([10, 2, 3, 4, 8, 11, 12, 20, 28, 84, 71, 89, 68, 999, 102]))
