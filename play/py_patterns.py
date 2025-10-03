from collections import Counter, defaultdict
from itertools import combinations, permutations, groupby

words = ["foo","bar","foo","baz","bar","foo"]
print("Counter:", Counter(words))

d = defaultdict(list)
for w in words:
d[w[0]].append(w) # bucket by first letter
print("defaultdict:", dict(d))

nums = [1,2,3]
print("combinations(2):", list(combinations(nums,2)))
print("permutations(3):", list(permutations(nums,3)))

data = sorted(["aa","ab","ba","bb","bc"])
print("groupby:", {k:list(g) for k,g in groupby(data, key=lambda s: s[0])})