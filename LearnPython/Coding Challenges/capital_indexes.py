""" Challenge
Capital indexes
Write a function named capital_indexes. The function takes a single parameter, which is a string. Your function should return a list of all the indexes in the string that have capital letters.

For example, calling capital_indexes("HeLlO") should return the list[0, 2, 4].
 """


def capital_indexes(word):
    letter_list = []
    for letter, letter_index in word:
        # Gotta remember the letter index HERE
        if letter.isupper():
            letter_index =  # int(word.index(letter))
            print(letter_index)
            letter_list.append(letter_index)
            # word.remove(letter_index)
        else:
            continue

    return letter_list


print(capital_indexes("TEsT"))
