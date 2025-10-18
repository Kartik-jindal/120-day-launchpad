from typing import List
from collections import Counter

# Sliding window solution for finding all anagrams
class Solution:  # define a Solution class to hold the method
    def findAnagrams(self, s: str, p: str) -> List[int]:  # method to find start indices of p's anagrams in s
        if len(p) > len(s):  # if pattern is longer than string, no anagrams possible
            return []  # return empty list immediately

        pCount, sCount = {}, {}  # initialize frequency dictionaries for pattern and current window in s
        for i in range(len(p)):  # build counts for the pattern and the first window of s of length len(p)
            pCount[p[i]] = 1 + pCount.get(p[i], 0)  # increment count of character p[i] in pattern counts
            sCount[s[i]] = 1 + sCount.get(s[i], 0)  # increment count of character s[i] in the initial window

        res = [0] if sCount == pCount else []  # if initial window matches pattern counts, include index 0
        left = 0  # left pointer for the sliding window starts at 0
        for right in range(len(p), len(s)):  # move right pointer from end of initial window to end of s
            sCount[s[right]] = 1 + sCount.get(s[right], 0)  # add the new char entering the window at position right
            sCount[s[left]] -= 1  # remove one occurrence of the char at left as it leaves the window
            if sCount[s[left]] == 0:  # if the count of that char becomes zero after decrement
                sCount.pop(s[left])  # remove the char key to keep dictionaries comparable
            left += 1  # advance the left pointer to reflect the slid window
            if sCount == pCount:  # if the current window's counts match the pattern's counts
                res.append(left)  # record the starting index of this anagram

        return res  # return all starting indices found
