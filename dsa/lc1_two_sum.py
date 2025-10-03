
# This is bruteforce method
# we are checking every combination of numbers
# time complexity is O(n^2)

class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        n = len(nums)
        for i in range(n):
            for j in range(i+1, n):
                if nums[i] + nums[j] == target:
                    return [i,j]
                

# This is optimal method
