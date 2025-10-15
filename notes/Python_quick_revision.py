# Quick_Revision_Python_Annotated.py
# Purpose: One-file, copy-pasteable DSA + dataclasses templates with “what and why” comments.
# Reading tip: each function starts with a short concept docstring, then key lines have inline WHY-explanations.

from __future__ import annotations  # allow forward references in type hints (e.g., "ListNode" inside its class)

from dataclasses import dataclass, field, asdict, replace  # dataclasses for lightweight models
from collections import deque, Counter  # deque for BFS queues; Counter for frequencies
from typing import List, Optional, Dict, Tuple  # type hints
import heapq  # priority queue ops for heap-based solutions


# =========================
# Arrays — Binary Search
# =========================

def binary_search(nums: List[int], target: int) -> int:
    """
    Binary Search (sorted array) → index or -1.
    Why it works: maintain an invariant that the answer (if exists) lies in the inclusive window [l, r].
    Each step halves the search space; l <= r ensures the middle element is checked.
    """
    l, r = 0, len(nums) - 1                     # invariant: if target exists, it's within [l, r]
    while l <= r:                                # stop when search window becomes empty
        m = (l + r) // 2                         # pick the middle to halve the space (integer division)
        if nums[m] == target:                    # if mid is the answer,
            return m                             # ...return immediately (found)
        if nums[m] < target:                     # if mid is too small,
            l = m + 1                            # ...discard left half incl. mid (target is to the right)
        else:                                    # if mid is too large,
            r = m - 1                            # ...discard right half incl. mid (target is to the left)
    return -1                                    # window exhausted → target not present


def search_rotated(nums: List[int], target: int) -> int:
    """
    Binary Search in a rotated sorted array (distinct values).
    Key property: at any point, either the left half [l..m] or the right half [m..r] is sorted.
    Strategy: detect the sorted half, then keep it only if target can lie inside its range.
    """
    l, r = 0, len(nums) - 1                      # inclusive window
    while l <= r:                                # classic BS loop
        m = (l + r) // 2                         # mid index
        if nums[m] == target:                    # direct hit
            return m
        if nums[l] <= nums[m]:                   # left half is sorted (no rotation in [l..m])
            if nums[l] <= target < nums[m]:      # target falls inside sorted left range
                r = m - 1                        # ...shrink to left half
            else:                                 # target not in left range
                l = m + 1                        # ...discard left half, keep right
        else:                                     # right half is sorted (rotation in left half)
            if nums[m] < target <= nums[r]:      # target falls inside sorted right range
                l = m + 1                        # ...shrink to right half
            else:                                 # target not in right range
                r = m - 1                        # ...discard right half, keep left
    return -1                                    # not found


# =========================
# Linked Lists
# =========================

@dataclass
class ListNode:
    val: int                                     # node value
    next: Optional["ListNode"] = None            # pointer to next node (or None)


def ll_from_list(values: List[int]) -> Optional[ListNode]:
    """
    Build a linked list from a Python list.
    Why dummy sentinel: simplifies linking without special-casing the head.
    """
    dummy = tail = ListNode(0)                   # dummy head so the first append is uniform
    for v in values:                             # iterate values in order
        tail.next = ListNode(v)                  # link a new node at the end
        tail = tail.next                         # advance the tail pointer
    return dummy.next                            # real head is after the dummy


def ll_to_list(head: Optional[ListNode]) -> List[int]:
    """
    Convert a linked list back to a Python list.
    Why: handy for testing and printing results.
    """
    out: List[int] = []                          # accumulator for values
    while head:                                  # traverse until None
        out.append(head.val)                     # collect current value
        head = head.next                         # advance pointer
    return out


def merge_two_lists(l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
    """
    Merge Two Sorted Lists (iterative, O(1) extra).
    Why dummy+tail: avoid head edge cases; always attach the smaller node and advance.
    """
    dummy = tail = ListNode(0)                   # sentinel head + moving tail for output list
    while l1 and l2:                             # while both lists have nodes
        if l1.val <= l2.val:                     # pick from l1 if it’s smaller/equal
            tail.next, l1 = l1, l1.next          # link l1 node; move l1 forward
        else:
            tail.next, l2 = l2, l2.next          # otherwise pick from l2
        tail = tail.next                         # advance tail to the newly linked node
    tail.next = l1 or l2                         # attach any remaining nodes in one shot
    return dummy.next                            # drop dummy and return real head


def reverse_list(head: Optional[ListNode]) -> Optional[ListNode]:
    """
    Reverse Linked List (iterative, O(1) extra).
    Why store nxt first: after flipping a pointer, the original next would be lost.
    """
    prev, curr = None, head                      # prev trails the reversed portion; curr scans forward
    while curr:                                  # iterate through the list
        nxt = curr.next                          # save next node BEFORE changing pointers
        curr.next = prev                         # flip the link to point backward
        prev, curr = curr, nxt                   # advance both pointers one step
    return prev                                  # prev ends at new head after loop


# =========================
# Trees (Binary): DFS/BFS
# =========================

@dataclass
class TreeNode:
    val: int
    left: Optional["TreeNode"] = None
    right: Optional["TreeNode"] = None


def max_depth_dfs(root: Optional[TreeNode]) -> int:
    """
    Maximum Depth via DFS recursion.
    Why: depth of a node = 1 (itself) + max(depth of left, depth of right).
    """
    if not root:                                 # base case: empty subtree
        return 0
    return 1 + max(                              # add current level
        max_depth_dfs(root.left),                # compute depth of left subtree
        max_depth_dfs(root.right)                # compute depth of right subtree
    )


def max_depth_bfs(root: Optional[TreeNode]) -> int:
    """
    Maximum Depth via BFS (level-order).
    Why: each full pass over the current queue size consumes exactly one level.
    """
    if not root:
        return 0
    depth, q = 0, deque([root])                  # start with root in queue
    while q:                                     # while there are nodes left to process
        depth += 1                               # we are entering a new level
        for _ in range(len(q)):                  # iterate exactly over current level size
            node = q.popleft()                   # pop a node of this level
            if node.left: q.append(node.left)    # queue children for next level
            if node.right: q.append(node.right)
    return depth                                 # number of levels processed


def level_order(root: Optional[TreeNode]) -> List[List[int]]:
    """
    Level Order Traversal (BFS).
    Why fix level size: prevents mixing nodes across levels when appending children.
    """
    if not root:
        return []
    out: List[List[int]] = []                    # list of levels (each a list of values)
    q = deque([root])                            # BFS queue
    while q:
        level: List[int] = []                    # collect values for this level
        for _ in range(len(q)):                  # freeze current level size
            n = q.popleft()                      # pop one node at this level
            level.append(n.val)                  # record its value
            if n.left: q.append(n.left)          # push children for next level
            if n.right: q.append(n.right)
        out.append(level)                        # append complete level
    return out


# =========================
# Graphs on Grid (BFS/DFS)
# =========================

DIRS: Tuple[Tuple[int, int], ...] = ((1, 0), (-1, 0), (0, 1), (0, -1))  # 4-direction neighbors: down/up/right/left


def num_islands(grid: List[List[str]]) -> int:
    """
    Number of Islands (grid of '1' land, '0' water), 4-direction connectivity.
    Why mutate: marking '1'→'0' as visited avoids a separate visited matrix and double counting.
    """
    if not grid:
        return 0
    R, C = len(grid), len(grid[0])               # grid bounds (rows, cols)
    def dfs(r: int, c: int) -> None:             # sink the entire connected component from (r, c)
        if r < 0 or r >= R or c < 0 or c >= C:   # stop if out of bounds
            return
        if grid[r][c] != '1':                    # stop if not land or already visited
            return
        grid[r][c] = '0'                         # mark current land cell as visited by turning it into water
        for dr, dc in DIRS:                      # explore four neighbors
            dfs(r + dr, c + dc)                  # recursively sink connected land
    count = 0                                    # number of components (islands)
    for r in range(R):                           # scan each cell
        for c in range(C):
            if grid[r][c] == '1':                # found a new island root
                count += 1                       # count this island
                dfs(r, c)                        # sink all connected land to avoid recount
    return count


def flood_fill(image: List[List[int]], sr: int, sc: int, color: int) -> List[List[int]]:
    """
    Flood Fill starting at (sr, sc).
    Why early-exit: if starting color already equals target, painting would create an infinite loop.
    Why paint-on-visit: painting doubles as 'visited' to avoid revisiting.
    """
    start = image[sr][sc]                        # color we are replacing
    if start == color:                           # nothing to do if already the target color
        return image
    R, C = len(image), len(image[0])             # bounds
    def dfs(r: int, c: int) -> None:
        if r < 0 or r >= R or c < 0 or c >= C:   # outside bounds → stop
            return
        if image[r][c] != start:                 # different color (or already painted) → stop
            return
        image[r][c] = color                      # paint current pixel (also marks visited)
        for dr, dc in DIRS:                      # recurse into 4-neighbors with the same start color
            dfs(r + dr, c + dc)
    dfs(sr, sc)                                  # start flood from the seed pixel
    return image


# =========================
# Heaps + Intervals
# =========================

def top_k_frequent(nums: List[int], k: int) -> List[int]:
    """
    Top K Frequent Elements (heap, O(n log k)).
    Why heap: when k << n, a heap avoids sorting the entire set; nlargest extracts k highest frequencies.
    """
    freq = Counter(nums)                         # build frequency map: num -> count
    return [x for x, _ in heapq.nlargest(        # take k items with largest counts
        k, freq.items(), key=lambda kv: kv[1]    # compare by frequency (dict item -> value)
    )]                                           # return only numbers (not counts)


def bucket_top_k(nums: List[int], k: int) -> List[int]:
    """
    Top K Frequent Elements (bucket method, O(n)).
    Why buckets: max frequency ≤ n; grouping by frequency lets us scan from high to low in linear time.
    """
    freq = Counter(nums)                         # frequency map
    buckets: List[List[int]] = [[] for _ in range(len(nums) + 1)]  # index = frequency; allocate n+1 buckets
    for x, c in freq.items():                    # place each number in its frequency bucket
        buckets[c].append(x)
    out: List[int] = []                          # collect top k
    for c in range(len(buckets) - 1, -1, -1):    # iterate frequencies from high to low
        for x in buckets[c]:                     # all numbers with this frequency
            out.append(x)                        # add to output
            if len(out) == k:                    # stop once we have k elements
                return out
    return out                                   # if fewer than k unique numbers, return what we have


def merge_intervals(intervals: List[List[int]]) -> List[List[int]]:
    """
    Merge Intervals (sort + one-pass).
    Why sort by start: ensures any overlaps can be resolved by comparing to just the last merged interval.
    Inclusive rule: if s <= last_end, there is overlap → extend the end.
    """
    intervals.sort(key=lambda it: it[0])         # sort by start time to bring overlaps together
    merged: List[List[int]] = []                 # output list of merged intervals
    for s, e in intervals:                       # process intervals in sorted order
        if not merged or s > merged[-1][1]:      # no overlap with the last merged interval
            merged.append([s, e])                # start a new merged interval
        else:                                    # overlap → extend the current merged end
            merged[-1][1] = max(merged[-1][1], e)
    return merged                                # merged, non-overlapping intervals


# =========================
# Python Dataclasses mini-crib
# =========================

@dataclass
class Rule:
    """
    A single targeting rule for a feature flag.
    Why default_factory: each instance gets its own dict; avoids shared mutable defaults bugs.
    """
    name: str                                    # human-friendly label
    percent_rollout: int = 0                     # allow up to this % of users that match (0..100)
    match_props: Dict[str, str] = field(default_factory=dict)  # properties that must match (e.g., {"region":"US"})


@dataclass
class Flag:
    """
    Feature Flag model with simple evaluation semantics.
    Why dataclass: concise, typed model; easy to serialize/clone in tests and services.
    """
    key: str                                     # unique key (e.g., "new-homepage")
    enabled: bool = False                        # master on/off
    rules: List[Rule] = field(default_factory=list)  # list of rules; default_factory = fresh list per instance

    def is_enabled_for(self, props: Dict[str, str], rollout_percent: Optional[int] = None) -> bool:
        """
        Evaluation policy:
        - If disabled → False.
        - If enabled and no rules → True (global on).
        - Otherwise, any rule with all match_props satisfied AND rollout_percent ≤ rule.percent_rollout → True.
        - rollout_percent=None means treat as 100 (i.e., only rules with 100% pass).
        Why this shape: mirrors common feature flag systems (targeting AND gradual rollout).
        """
        if not self.enabled:                     # global switch off
            return False
        if not self.rules:                       # no targeting → everybody gets it
            return True
        eff = 100 if rollout_percent is None else max(0, min(100, rollout_percent))  # clamp to [0,100] for safety
        for r in self.rules:                     # inspect each targeting rule
            # match if ALL required properties match exactly (logical AND across keys)
            if all(props.get(k) == v for k, v in r.match_props.items()):
                if eff <= r.percent_rollout:     # pass rollout gate (e.g., 10 ≤ 25%)
                    return True                  # one matching rule is enough to enable
        return False                              # no rule matched with sufficient rollout


# =========================
# Minimal Demos (safe to remove)
# =========================

if __name__ == "__main__":
    # Arrays
    print("binary_search:", binary_search([-1, 0, 3, 5, 9, 12], 9))            # expect 4
    print("search_rotated:", search_rotated([4, 5, 6, 7, 0, 1, 2], 0))         # expect 4

    # Linked Lists
    a = ll_from_list([1, 2, 4]); b = ll_from_list([1, 3, 4])                   # build two sorted lists
    print("merge_two_lists:", ll_to_list(merge_two_lists(a, b)))                # [1,1,2,3,4,4]
    print("reverse_list:", ll_to_list(reverse_list(ll_from_list([1, 2, 3]))))   # [3,2,1]

    # Trees
    t = TreeNode(1, TreeNode(2, TreeNode(4)), TreeNode(3))                      # small test tree
    print("max_depth_dfs:", max_depth_dfs(t), "bfs:", max_depth_bfs(t))         # 3 3
    t2 = TreeNode(3, TreeNode(9), TreeNode(20, TreeNode(15), TreeNode(7)))
    print("level_order:", level_order(t2))                                       # [[3],[9,20],[15,7]]

    # Graphs (grid)
    g = [["1", "1", "0", "0", "0"],
         ["1", "1", "0", "0", "0"],
         ["0", "0", "1", "0", "0"],
         ["0", "0", "0", "1", "1"]]
    print("num_islands:", num_islands([row[:] for row in g]))                    # expect 3

    img = [[1, 1, 1], [1, 1, 0], [1, 0, 1]]
    print("flood_fill:", flood_fill([row[:] for row in img], 1, 1, 2))           # [[2,2,2],[2,2,0],[2,0,1]]

    # Heaps + Intervals
    print("top_k_frequent:", top_k_frequent([1, 1, 1, 2, 2, 3], 2))              # [1,2] (order may vary)
    print("bucket_top_k:", bucket_top_k([1, 1, 1, 2, 2, 3], 2))                  # [1,2]
    print("merge_intervals:", merge_intervals([[1, 3], [2, 6], [8, 10], [15, 18]]))  # [[1,6],[8,10],[15,18]]

    # Dataclasses
    r1 = Rule("IN 25%", 25, {"region": "IN"}); r2 = Rule("US 100%", 100, {"region": "US"})
    flag = Flag("homepage", True, [r1, r2])
    print("flag US@5%:", flag.is_enabled_for({"region": "US"}, 5))               # True (5 ≤ 100)
    print("flag IN@30%:", flag.is_enabled_for({"region": "IN"}, 30))             # False (30 > 25)
    print("asdict(flag):", asdict(flag))                                         # nested dict snapshot
    print("replace(flag, enabled=False):", replace(flag, enabled=False))         # copy with update (immutable-style)