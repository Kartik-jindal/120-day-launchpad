# Definition for a binary tree node.
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right
class Solution:
    def rightSideView(self, root: Optional[TreeNode]) -> List[int]:
        res = []
        q = collections.deque([root]) # initialize queue with root node , it has only 1 big element i.e. level 0 of tree

        while q:
            rightside = None # to keep track of the rightmost node at the current level initially set to None
            qlen = len(q) # number of nodes at the current level
            for i in range(qlen): # iterate through all nodes at the current level
                node = q.popleft()  # dequeue the front node from the queue
                if node: # if the node is not None , update rightside to the current node, so after the loop it will be the right
                    rightside = node
                    q.append(node.left)
                    q.append(node.right)
            if rightside:
                res.append(rightside.val) # append the value of the rightmost node to the result list
        return res