class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        prev , curr = None, head
        while curr: # iterate through the linked list and reverse the pointers
            nxt = curr.next # store the next node so that we don't lose the reference to the rest of the list 
            curr.next = prev  # reverse the pointer of the current node to point to the previous node
            prev = curr # move the prev and curr pointers one step forward so that we can continue reversing the rest of the list
            curr = nxt # at the end of the loop, prev will be pointing to the new head of the reversed list
        return prev
