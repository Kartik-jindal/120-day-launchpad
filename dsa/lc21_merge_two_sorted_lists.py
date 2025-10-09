class ListNode:
    def __init__(self, val=0, next: Optional["ListNode"]=None):
        self.val, self.next = val, next

class Solution:
    def mergeTwoLists(self, l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]: 
        dummy = tail = ListNode() # makes a dummy head which helps in easily returning the head of the merged list later without returning None
        while l1 and l2:
            if l1.val <= l2.val:
                tail.next, l1 = l1, l1.next
            else:
                tail.next, l2 = l2, l2.next
            tail = tail.next # move the tail pointer to the end of the merged list if one of the lists is none, append the remaining elements of the other list
        tail.next = l1 or l2 # after the loop, at least one of l1 and l2 is None so we can directly append the non-None list to the merged list 
        return dummy.next