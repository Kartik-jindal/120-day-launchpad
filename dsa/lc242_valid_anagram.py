''' using hashmap '''
class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        if len(s) != len(t):
            return False
        
        countS, countT = {}, {}
        
        for i in range(len(s)):
            countS[s[i]] = 1 + countS.get(s[i], 0) #get(value , default value if not present) will take the value if present or use 0 if none
            countT[t[i]] = 1 + countT.get(t[i], 0) 
        for c in countS:
            if countS[c] != countT.get(c, 0):
                return False
        return True
    


''' other method by sorting'''
class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        if sorted(list(s)) == sorted(list(t)):
            return True
        else:
            return False