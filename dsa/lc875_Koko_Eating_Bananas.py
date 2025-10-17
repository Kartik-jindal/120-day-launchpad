class Solution:
    def minEatingSpeed(self, piles: List[int], h: int) -> int:
        l , r =  1 , max(piles) # initialize left and right pointers by 1 and max pile size
        res = r
        while l<=r:
            k = (l+r)//2
            hours = 0
           
            for i in piles:
                hours += math.ceil(i/k)
            if hours<=h:
                res = min(res, k)
                r = k-1
            else:
                l = k+1
        return res
