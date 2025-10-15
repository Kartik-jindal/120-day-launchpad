from typing import Optional
from collections import deque

# recursive method
class TreeNode:
    def __init__(self, val=0, left=None, right=None): # deifining a binary tree node
        self.val = val #root node value
        self.left = left # left child
        self.right = right # right child

class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int: #takes either a tree node or None as input in root which is a binary tree
        if not root: #if the root is empty give depth as 0
            return 0
        return 1 + max(self.maxDepth(root.left), self.maxDepth(root.right)) # recursively call the function on left and right child and return the max depth between the two + 1 for the root node

# Breadth First Search Traversal (BFS) method
class SolutionBFS:
    def maxDepth(self, root: Optional[TreeNode]) -> int:
        if not root:
            return 0
        level = 0 # initialize level to 0
        queue = deque([root])
        while queue:
            for i in range(len(queue)):
                current = queue.popleft() # Dequeue the front node in order to process it.
                if current.left: 
                    queue.append(current.left) # enqueue left child
                if current.right:
                    queue.append(current.right) # enqueue right child
            level += 1 # increment level after processing all nodes at the current level
        return level # return the total number of levels as the maximum depth

# DFS
# Iterative method
#  uses stack data structure
class Solution:
    def maxDepth(self, root: Optional[TreeNode]) -> int: #takes either a tree node or None as input in root which is a binary tree
        if not root: #if the root is empty give depth as 0
            return 0
        stack = [(root, 1)] # Initialize the stack with the root node and its depth (1).,                
        max_depth = 0 # Initialize max_depth to keep track of the maximum depth encountered.
        while stack:
            current, depth = stack.pop() # Pop the top node and its depth from the stack.
            if current: # If the current node is not None:
                max_depth = max(max_depth, depth) # Update max_depth if the current depth is greater.
                # Push the left and right children onto the stack with incremented depth.
                stack.append((current.left, depth + 1)) 
                stack.append((current.right, depth + 1))
        return max_depth # Return the maximum depth found.