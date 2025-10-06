# 206. Reverse Linked List
# iterative approach

class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        prev , curr = None, head
        while curr:
            nxt = curr.next
            curr.next = prev
            prev = curr
            curr = nxt
        return prev

#  recursive approach
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        if not head or not head.next:
            return head
        p = self.reverseList(head.next)
        head.next.next = head
        head.next = None
        return p
    
# 876. Middle of the Linked List
 class Solution:
    def middleNode(self, head: Optional[ListNode]) -> Optional[ListNode]:
        slow , fast = head , head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
        return slow
    

# 141. Linked List Cycle
class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        slow  , fast = head , head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if slow== fast:
                return True
        return False