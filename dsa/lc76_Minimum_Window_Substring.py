class Solution:
    def minWindow(self, s: str, t: str) -> str: 
        if t == "":     # if t is empty, return empty string
            return ""
        countT = {} # count of chars in t
        window = {} # count of chars in current window
        res , reslen = [-1 ,-1] , float("infinity") # initialize result and its length by using default values as infinity and -1 indexes
        l = 0 # left pointer of the window
        for c in t: #makes CountT dictionary
            countT[c] = 1 + countT.get(c ,0)
        have , need = 0 , len(countT) # initialize how many unique chars we have and how many we need
        
        for r in range(len(s)): # right pointer of the window
            c = s[r] # current char
            window[c] = 1 + window.get(c ,0) #creating window dictionary by adding current char and its count
            if c in countT and window[c] == countT[c]: # if current char is in countT and its count in window is equal to its count in countT
                have += 1 # increment have by 1 so that we know we have one more unique char in the window
            while have == need: # if we have all the unique chars we need
                if (r-l+1) < reslen: # if the current window length is less than the result length
                    res = [l,r]
                    reslen = r-l+1
                window[s[l]] -= 1   # decrement the count of the char at the left pointer in the window so that we can try to minimize the window
                if s[l] in countT and window[s[l]] < countT[s[l]]: # if the char at the left pointer is in countT and its count in window is less than its count in countT
                    have -=1 #reduce have by 1 so that we know we don't have all the unique chars we need and we need to expand the window again
                l +=1 # move the left pointer to the right to minimize the window
        l , r = res # unpack the result indexes by using res variable as a list
        return s[l:r+1] if reslen != float("infinity") else ""  # if reslen is not infinity, return the substring from l to r+1, else return empty string