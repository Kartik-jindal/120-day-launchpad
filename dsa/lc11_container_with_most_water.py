#brute force method

class Solution:
    def maxArea(self, hieght: List[int]) -> int:

        ar = 0
        for l in range(len(hieght)):
            for r in range(l+1 , len(hieght)):
                area = (r-l)*min(hieght[l],hieght[r])
                ar = max(ar ,area)
        return ar
    

#optimal method
class Solution:
    def maxArea(self, height: List[int]) -> int:
        l, r = 0 , len(height) -1
        arr = 0
        while l<r:
            area = (r-l) * min(height[r],height[l])
            arr = max(area , arr)
            if height[l]<height[r]:
                l += 1
            else:
                r -=1
            
        return arr