'''Hash set method'''

class Solution:
    def containsDuplicate(self, nums: List[int]) -> bool:
        check = set() #creating a set to store unique elements
        for num in nums: #iterating through the list
            if num in check: #check if the number is already in the set
                return True #if yes then that means we have a duplicate so return True
            check.add(num) #Checked through the set and did not find the number so add it to the set
        return False #if we reach here that means we did not find any duplicates so return False
    
'''Brute force method'''
class Solution:
    def containsDuplicate(self, nums: List[int]) -> bool:
        a = list()
        for i in nums:
            a.append(nums.count(i))
        for j in a:
            if j >= 2:
                return True
        return False  # only return False after checking all
