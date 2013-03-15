from collections import OrderedDict
import string
from pprint import pprint

from genetic_algorithms.cCrossover import ConfinedSwapCrossover


if __name__ == '__main__':
    permutations = OrderedDict([
        ('a', [(2, 0), (1, 2), (2, 1), (0, 0), (1, 1)]),
        ('b', [(1, 1), (2, 0), (1, 2), (1, 0), (0, 1)]),
    ])

    swaps = ConfinedSwapCrossover(permutations['a'],
                                permutations['b']).get_swaps(seed=1132)

    convert_chars = string.ascii_uppercase

    if len(permutations['a']) <= len(convert_chars):
        for s in swaps:
            for k in ('source', 'target'):
                if s[k] is not None:
                    s[k] = convert_chars[s[k]]

    pprint(swaps)
