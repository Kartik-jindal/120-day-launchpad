class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        a = set() # to store unique characters
        l = 0 # left pointer
        result = 0
        for r in range(len(s)): # right pointer which will move forward starting from 0
            while s[r] in a:  # if the character at right pointer is already in the set, we need to move the left pointer to the right until we remove the duplicate character
                a.remove(s[l]) # remove the character at left pointer from the set and move left pointer to the right
                l+=1
            a.add(s[r])
            result = max( result , r-l+1) # update the result with the maximum length found so far
        return result 
