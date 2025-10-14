class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        tab = {} # dictionary to store frequency of each element
        res = [] # result list to store top k frequent elements 
        for i in nums:
            tab[i] = 1+ tab.get(i , 0)  # counting frequency of each element using dictionary
        
        sorted_items = sorted(tab.items(), key=lambda item: item[1], reverse=True) # sorting dictionary items by frequency in descending order
        res = [item[0] for item in sorted_items[:k]] # getting top k elements by using each item's key from sorted items and slicing first k elements
        return res