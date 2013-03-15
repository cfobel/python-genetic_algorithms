from datetime import datetime
import logging
from copy import deepcopy
from collections import OrderedDict

import numpy as np


class SwapGenerator(object):
    def __init__(self, maps, seed=0):
        self.maps = maps
        self.rand_state = np.random.RandomState()
        self.rand_state.seed(seed)
        self.swap_order = self.maps['a'].keys()
        self.rand_state.shuffle(self.swap_order)
        self.count = len(self.swap_order)
        self.reverse_maps = {}

        # Make a copy of parent as a starting point
        self.reset()
        # Since we do not modify the `b` reverse map, we only need to
        # initialize it once.
        self.reset_reverse_map('b')

    def reset(self):
        # Make a copy of parent as a starting point
        self.reset_reverse_map('a')
        self._dirty = False

    def reset_reverse_map(self, label):
        self.reverse_maps[label] = dict([(v, k)
                for k, v in self.maps[label].iteritems()])

    def swap_iterator(self):
        if self._dirty:
            self.reset()
        else:
            self._dirty = True

        swap_order = self.swap_order[:]
        to_move = OrderedDict()

        a_map = self.maps['a']
        b_map = self.maps['b']
        r = self.reverse_maps
        b_r, a_r = r['b'], r['a']

        for key in swap_order:
            swap = {'key': key, 'source': a_map[key]}
            if key in b_map:
                # The corresponding key is present in the `b` map, so select
                # the corresponding value as the target.
                swap['target'] = b_map[key]
            else:
                # There is no value corresponding to the source key, so,
                # postpone until the end, but re-adding the key to the end of
                # the swap order.
                to_move[key] = key
                continue

            if swap['source'] == swap['target']:
                # This swap is unnecessary, so skip to the next one
                continue
            swap['source_element'] = a_r[swap['source']]
            swap['target_element'] = a_r[swap['target']]

            a_map[swap['source_element']] = swap['target']
            a_map[swap['target_element']] = swap['source']
            a_r[swap['source']], a_r[swap['target']] = a_r[swap['target']], a_r[swap['source']]

            yield swap

        # Process moves from old key to new key (i.e., handle keys that are not
        # present in both maps `a` and `b`).  This requires removing the entry
        # for the original key from map `a`, and re-adding it to the map with
        # the key for the corresponding value from map `b`.
        #
        # N.B. Since both maps `a` and `b` must contain the same set of values,
        # we can be sure that the key from map `b` will be unoccupied in map
        # `a` at this point.
        for key in to_move.values():
            swap = {'key': key, 'source': a_map[key]}
            swap['source_element'] = key
            swap['target'] = None
            swap['target_element'] = b_r[swap['source']]

            del a_map[swap['source_element']]
            a_map[swap['target_element']] = swap['source']
            r['a'][swap['source']] = swap['target_element']

            yield swap


def do_swaps(maps, count=None, seed=0):
    s = SwapGenerator(maps, seed=seed)
    if count is None:
        count = len(s.swap_order)
    if count > 0:
        for i, swap in enumerate(s.swap_iterator()):
            #print('do_swaps:', swap)
            if i + 1 >= count:
                break
    return s.reverse_maps['a']


def get_swaps(maps, seed=0):
    s = SwapGenerator(maps, seed)
    count = len(s.swap_order)
    if count > 0:
        swaps = [swap for swap in s.swap_iterator()]
    else:
        swaps = []
    return swaps


class ConfinedSwapCrossover(object):
    def __init__(self, a, b):
        self.p = OrderedDict([
            ('a', a),
            ('b', b),
        ])
        self.maps = OrderedDict([
            ('a', OrderedDict()),
            ('b', OrderedDict()),
        ])

        opposite = {'a': 'b', 'b': 'a'}

        for label in ['a', 'b']:
            m = self.maps[label]
            opposite_p = self.p[opposite[label]]
            for i, element in enumerate(self.p[label]):
                if opposite_p[i] != element:
                    m[element] = i

    def do_swaps(self, count=None, seed=0):
        return do_swaps(self.maps, count, seed=seed)

    def get_swaps(self, seed=0):
        return get_swaps(self.maps, seed)


def run_test(key_count=100000):
    c = ConfinedSwapCrossover(range(key_count), range(key_count, 0, -1))
    c.do_swaps()
