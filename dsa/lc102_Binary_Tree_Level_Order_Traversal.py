# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        res = []
        q = collections.deque()
        if root:
            q.append(root)
        while q:
            levels= []
            for i in range(len(q)):
                current = q.popleft()
                if current:
                    levels.append(current.val)
                    q.append(current.left)
                    q.append(current.right)
            if levels:
                res.append(levels)
        return res