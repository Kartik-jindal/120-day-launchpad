#fastest method
import string
class Solution:
    def isPalindrome(self, s: str) -> bool:
        a = string.ascii_letters + string.digits # all alphanumeric characters
        b = [] # list to store the filtered characters
        for i in s:
            if i in a:  # check if the character is alphanumeric
                b.append(i.lower()) # convert to lowercase and add to the list so that the comparison is case insensitive
        return b == b[::-1] # check if the list is equal to its reverse
    

# other method with better memory

class Solution:
    def isPalindrome(self, s: str) -> bool:
        l , r = 0 , len(s) -1 # two pointers at both ends
        while l<r: # loop until the pointers meet in the middle
            while l<r and not self.alphanum(s[l]): # move the left pointer to the right until it points to an alphanumeric character
                l += 1 # move the left pointer to the right if it's not alphanumeric
            while r>l and not in self,alphanum(s[r]):
                r -= 1 # move the right pointer to the left if it's not alphanumeric
            if s[l].lower() != s[r].lower():
                return False # if the characters at the pointers are not equal, return False
            l , r = l+1 , r-1 # move both pointers towards the middle
        return True # if the loop completes, the string is a palindrome
    
    def alphanum(self , c):
        return (ord('A') <= ord(c)<= ord('Z')) or (ord('a') <= ord(c)<= ord('z')) or (ord('0') <= ord(c)<= ord('9')) 
    # this function checks if the character is alphanumeric and returns True or False