# building block class of a tree

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val #parent node value initialized as 0  
        self.left = left #left child node initialized as None
        self.right = right #right child node initialized as None


#Depth First Search Traversal
#Inorder Traversal - Left, Root, Right
#uses stack data structure
#goes left to the end, then backtracks to the parent node, then goes right
# we push the right child first so that the left child is processed first from top of the stack
# we check till the stack is empty and current node doesn't have any child
# Blueprint for Recursive DFS (Pre-order: Root -> Left -> Right):


class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def process(val): # the function to process the node value
    print(val) # prints the current node value

def dfs(node):
    # Base Case: The path ends here.
    if not node:
        return
    
    # 1. Process the current node (Pre-order).
    process(node.val)
    
    # 2. Recurse on the left subtree.
    dfs(node.left)
    
    # 3. Recurse on the right subtree.
    dfs(node.right)

# Breadth First Search Traversal
# Level Order Traversal - Level by Level
# uses queue data structure
# we enqueue the left child first so that it is processed first from the front of the queue
# we check till the queue is empty
# Blueprint for BFS:    

from collections import deque
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def process(val): # the function to process the node value
    print(val) # prints the current node value
 
def bfs(root):
    if not root:
        return
    
    queue = deque([root]) # Initialize the queue with the root node.
    
    while queue:
        current = queue.popleft() # Dequeue the front node in order to process it.
        
        # 1. Process the current node.
        process(current.val) #
        
        # 2. Enqueue the left child if it exists.
        if current.left:
            queue.append(current.left)
        
        # 3. Enqueue the right child if it exists.
        if current.right:
            queue.append(current.right)