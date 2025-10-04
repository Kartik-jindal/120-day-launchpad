''' hashing with dictionary method'''

from collections import defaultdict
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        final = defaultdict(list)
        for i in strs:
            key = tuple(sorted(i))
            final[key].append(i)
        return list(final.values())

''' counting method'''
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        res = defaultdict(list) # dictionary to store the result
        for s in strs:  # iterate through each string in the input list
            count = [0] * 26 # list to store count of each character by index
            for c in s:     # iterate through each character in the string
                count[ord(c) - ord('a')] += 1 # increment the count of the character at its respective index, ord() gives the ASCII value of the character
            res[tuple(count)].append(s) # use the count list as a key in the dictionary and append the string to the corresponding list
        return list(res.values()) # return the values of the dictionary as a list of lists