class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        countS = {}
        countT = {}
        for i in s:
            countS[i] = 1 + countS.get(i ,0)
        
        for j in t:
            countT[j] = 1 + countT.get(j,0)
        
        return countS == countT
    
