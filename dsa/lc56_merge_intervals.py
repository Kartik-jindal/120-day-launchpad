class Solution:
    def merge(self, intervals: List[List[int]]) -> List[List[int]]:
        intervals.sort(key = lambda i:i[0]) # sorting by first element of each list in big list named intervals
        output = [intervals[0]] # initializing output with first interval to compare with rest of the intervals
        for start , end in intervals[1:]: # iterating through rest of the intervals by unpacking start and end values using slicing
            lastend = output[-1][1] # getting the end value of last list in output list
            if start<=lastend: # if start of current list is less than or equal to last end of output list
                output[-1][1] = max( lastend, end) # changing the end value to the maximum of lastend and current end
            else:
                output.append([start , end]) #if there is no overlap just append the current interval to output list
        return output