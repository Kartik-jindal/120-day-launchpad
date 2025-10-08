
class Solution:
    def dailyTemperatures(self, temperature: List[int]) -> List[int]:
        n = len(temperature)
        stack = []
        result = [0] * n
        for i in range(n-1 , -1 , -1):
            while stack and temperature[i] >= temperature[stack[-1]]:
                stack.pop()

            if stack:
                result[i] = stack[-1] - i

            stack.append(i)
        return result