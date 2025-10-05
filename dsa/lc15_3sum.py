#works but not optimal because of 3 nested loops and time complexity O(n^3) 
class Solution:
    def threeSum(self, nums: List[int]) -> List[List[int]]:
        a = list()
        seen = set()
        for i in range(len(nums)):
            for j in range(i+1 , len(nums)):
                for k in range(j+1 , len(nums)):
                    if nums[i] + nums[j] + nums[k]== 0:
                        triplet = sorted([nums[i] , nums[k] , nums[j]])
                        t = tuple(triplet)
                        if t not in seen:
                            a.append(t)
                            seen.add(t)
        return a
    
#optimal solution using 2 pointer approach and time complexity O(n^2)
class Solution:
    def threeSum(self, nums: List[int]) -> List[List[int]]:
        a = list() 
        nums.sort()
        for i , j in enumerate(nums): # i is index and j is value using enumerate
            if i>0 and nums[i] == nums[i-1]: # to avoid duplicates at consecutive positions
                continue
            l , r = i+1 , len(nums)- 1  # left and right pointers 
            while l<r: # until left pointer is less than right pointer
                sums = nums[i] + nums[l] + nums[r] # calculating sum of 3 numbers
                # moving pointers based on sum value
                if sums > 0 :
                    r-=1
                elif sums<0:
                    l+=1
                else:
                    a.append([nums[i],nums[l],nums[r]])
                    l += 1 # moving left pointer manually when we found a triplet 

                    while nums[l] == nums[l-1] and l<r: # to avoid duplicates at consecutive positions while moving left pointer
                        l+=1
        return a
