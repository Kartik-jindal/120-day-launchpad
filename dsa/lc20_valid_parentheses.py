class Solution:
    def isValid(self, s: str) -> bool:
        stack=[]
        mapping = {')': '(', ']': '[', '}': '{'}   #mapping of closing to opening brackets
        for char in s:
            if char in mapping.values(): # if it's one of '(', '[', '{' then push onto stack
                stack.append(char)
            elif char in mapping: # if it's one of ')', ']', '}' then check for matching opening bracket 
                 # if stack is empty or top of stack doesn't match the corresponding opening bracket, return False
                if not stack or stack[-1] != mapping[char]: # if stack is empty or top of stack doesn't match the corresponding opening bracket
                    return False
                stack.pop()
            else:
                return False
        return not stack
    

    