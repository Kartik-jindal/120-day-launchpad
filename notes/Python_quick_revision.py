# Python_Mega_Revision.py
# Purpose: One-file, copy-pasteable reference of core DSA patterns + a small dataclasses crib.
# Style: short what/why comments so you can recall the idea quickly.

from __future__ import annotations  # allow forward-referenced type hints

from dataclasses import dataclass, field, asdict, replace  # lightweight, typed models
from collections import deque, Counter  # BFS queue; frequency counting
from typing import List, Optional, Dict, Tuple  # type hints
import heapq  # priority queue for heap-based top-K
import math   # ceil for rate/capacity feasibility


# =========================
# Arrays — Binary Search
# =========================

def binary_search(nums: List[int], target: int) -> int:
    """
    Classic binary search (sorted nums) -> index or -1.
    Why: keep an invariant that the answer (if exists) lies in [l, r]; each step halves the space.
    """
    l, r = 0, len(nums) - 1  # inclusive window
    while l <= r:  # stop when window is empty
        m = (l + r) // 2
        if nums[m] == target:
            return m  # found
        if nums[m] < target:
            l = m + 1  # keep right half
        else:
            r = m - 1  # keep left half
    return -1  # not found


def search_rotated(nums: List[int], target: int) -> int:
    """
    Binary search in a rotated sorted array (distinct values).
    Why: at each step, one half is sorted; only keep the half that can contain target.
    """
    l, r = 0, len(nums) - 1
    while l <= r:
        m = (l + r) // 2
        if nums[m] == target:
            return m
        if nums[l] <= nums[m]:  # left half sorted
            if nums[l] <= target < nums[m]:
                r = m - 1
            else:
                l = m + 1
        else:  # right half sorted
            if nums[m] < target <= nums[r]:
                l = m + 1
            else:
                r = m - 1
    return -1


# =========================
# Binary Search on Answer
# =========================

def bs_on_answer(lo: int, hi: int, can) -> int:
    """
    Generic 'search the answer' helper (find minimal feasible k).
    When: feasibility can(k) is monotone (False False ... True True).
    """
    l, r, ans = lo, hi, hi
    while l <= r:
        m = (l + r) // 2
        if can(m):          # m works → remember it and try smaller
            ans, r = m, m - 1
        else:               # m fails → try larger
            l = m + 1
    return ans


def koko_min_eating_speed(piles: List[int], h: int) -> int:
    """
    LC 875 — Koko Eating Bananas.
    Why BS on k: if she can finish with speed k, she can finish with any k' > k (monotone).
    """
    l, r = 1, max(piles)
    def can(k: int) -> bool:
        return sum(math.ceil(p / k) for p in piles) <= h  # ceil hours per pile
    return bs_on_answer(l, r, can)


def ship_within_days(weights: List[int], days: int) -> int:
    """
    LC 1011 — Capacity to Ship Packages Within D Days.
    Why BS on capacity: if capacity works within D days, any larger capacity works (monotone).
    """
    l, r = max(weights), sum(weights)
    def can(cap: int) -> bool:
        used_days, curr = 1, 0
        for w in weights:
            if curr + w > cap:  # start new day
                used_days += 1
                curr = 0
            curr += w
        return used_days <= days
    return bs_on_answer(l, r, can)


# =========================
# Prefix Sums
# =========================

def subarray_sum_equals_k(nums: List[int], k: int) -> int:
    """
    LC 560 — Subarray Sum Equals K.
    Why: pref[j] - pref[i] == k -> subarray (i..j-1) sums to k.
         Count how many previous prefixes equal pref - k.
    """
    from collections import defaultdict
    cnt = defaultdict(int)
    cnt[0] = 1         # empty prefix enables subarrays starting at index 0
    pref = ans = 0
    for x in nums:
        pref += x
        ans += cnt[pref - k]  # add all starts i where pref[i] == pref - k
        cnt[pref] += 1        # record this prefix for future ends
    return ans


# =========================
# Linked Lists
# =========================

@dataclass
class ListNode:
    val: int
    next: Optional["ListNode"] = None


def ll_from_list(values: List[int]) -> Optional[ListNode]:
    """Helper: Python list -> linked list (useful in tests)."""
    dummy = tail = ListNode(0)
    for v in values:
        tail.next = ListNode(v)
        tail = tail.next
    return dummy.next


def ll_to_list(head: Optional[ListNode]) -> List[int]:
    """Helper: linked list -> Python list."""
    out: List[int] = []
    while head:
        out.append(head.val)
        head = head.next
    return out


def merge_two_lists(l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
    """
    Merge Two Sorted Lists (iterative, O(1) extra).
    Why dummy+tail: avoid head edge cases; always attach the smaller node and advance.
    """
    dummy = tail = ListNode(0)
    while l1 and l2:
        if l1.val <= l2.val:
            tail.next, l1 = l1, l1.next
        else:
            tail.next, l2 = l2, l2.next
        tail = tail.next
    tail.next = l1 or l2  # append remainder
    return dummy.next


def reverse_list(head: Optional[ListNode]) -> Optional[ListNode]:
    """
    Reverse Linked List (iterative).
    Why save nxt: after flipping pointer you’d lose the rest without it.
    """
    prev, curr = None, head
    while curr:
        nxt = curr.next
        curr.next = prev
        prev, curr = curr, nxt
    return prev


# =========================
# Trees (Binary): DFS/BFS
# =========================

@dataclass
class TreeNode:
    val: int
    left: Optional["TreeNode"] = None
    right: Optional["TreeNode"] = None


def max_depth_dfs(root: Optional[TreeNode]) -> int:
    """Depth = 1 + max(depth(left), depth(right)); base case None -> 0."""
    if not root:
        return 0
    return 1 + max(max_depth_dfs(root.left), max_depth_dfs(root.right))


def max_depth_bfs(root: Optional[TreeNode]) -> int:
    """
    Level-order (BFS) depth.
    Why len(q) loop: freeze level size so you add exactly one to depth per layer.
    """
    if not root:
        return 0
    depth, q = 0, deque([root])
    while q:
        depth += 1
        for _ in range(len(q)):  # process one full level
            node = q.popleft()
            if node.left: q.append(node.left)
            if node.right: q.append(node.right)
    return depth


def level_order(root: Optional[TreeNode]) -> List[List[int]]:
    """Return values per level using BFS."""
    if not root:
        return []
    out: List[List[int]] = []
    q = deque([root])
    while q:
        row: List[int] = []
        for _ in range(len(q)):
            n = q.popleft()
            row.append(n.val)
            if n.left: q.append(n.left)
            if n.right: q.append(n.right)
        out.append(row)
    return out


# =========================
# Graphs on Grid (BFS/DFS)
# =========================

DIRS: Tuple[Tuple[int, int], ...] = ((1, 0), (-1, 0), (0, 1), (0, -1))  # 4-dir neighbors


def num_islands(grid: List[List[str]]) -> int:
    """
    LC 200 — Number of Islands (4-dir).
    Why mutate: mark '1'->'0' as visited to avoid separate visited[] and double-counting.
    """
    if not grid:
        return 0
    R, C = len(grid), len(grid[0])

    def dfs(r: int, c: int) -> None:
        if r < 0 or r >= R or c < 0 or c >= C or grid[r][c] != '1':
            return
        grid[r][c] = '0'
        for dr, dc in DIRS:
            dfs(r + dr, c + dc)

    count = 0
    for r in range(R):
        for c in range(C):
            if grid[r][c] == '1':
                count += 1
                dfs(r, c)
    return count


def flood_fill(image: List[List[int]], sr: int, sc: int, color: int) -> List[List[int]]:
    """
    LC 733 — Flood Fill.
    Why early-exit: if start==color, painting would loop infinitely; painting acts as 'visited'.
    """
    start = image[sr][sc]
    if start == color:
        return image
    R, C = len(image), len(image[0])

    def dfs(r: int, c: int) -> None:
        if r < 0 or r >= R or c < 0 or c >= C or image[r][c] != start:
            return
        image[r][c] = color
        for dr, dc in DIRS:
            dfs(r + dr, c + dc)

    dfs(sr, sc)
    return image


# =========================
# Heaps + Intervals
# =========================

def top_k_frequent(nums: List[int], k: int) -> List[int]:
    """
    LC 347 — Top K Frequent (heap, O(n log k)).
    Why heap: avoid sorting entire set when k << n; nlargest picks top-k by frequency.
    """
    freq = Counter(nums)
    return [x for x, _ in heapq.nlargest(k, freq.items(), key=lambda kv: kv[1])]


def bucket_top_k(nums: List[int], k: int) -> List[int]:
    """
    Top K Frequent (bucket, O(n)).
    Why buckets: max frequency ≤ n → group by frequency index and scan high→low.
    """
    freq = Counter(nums)
    buckets: List[List[int]] = [[] for _ in range(len(nums) + 1)]
    for x, c in freq.items():
        buckets[c].append(x)
    out: List[int] = []
    for c in range(len(buckets) - 1, -1, -1):
        for x in buckets[c]:
            out.append(x)
            if len(out) == k:
                return out
    return out


def merge_intervals(intervals: List[List[int]]) -> List[List[int]]:
    """
    LC 56 — Merge Intervals.
    Why sort by start: comparing to only the last merged interval is enough to decide overlap.
    """
    intervals.sort(key=lambda it: it[0])
    merged: List[List[int]] = []
    for s, e in intervals:
        if not merged or s > merged[-1][1]:  # disjoint
            merged.append([s, e])
        else:  # overlapping → extend end
            merged[-1][1] = max(merged[-1][1], e)
    return merged


# =========================
# Python Dataclasses mini-crib
# =========================

@dataclass
class Rule:
    """
    Targeting rule for a feature flag.
    Why default_factory: each instance gets its own dict (no shared mutable defaults).
    """
    name: str
    percent_rollout: int = 0                      # 0..100 gate
    match_props: Dict[str, str] = field(default_factory=dict)  # e.g., {"region": "US"}


@dataclass
class Flag:
    """
    Feature Flag model with simple evaluation semantics.
    Why dataclass: concise, typed model; easy to serialize/clone (asdict/replace).
    """
    key: str
    enabled: bool = False
    rules: List[Rule] = field(default_factory=list)

    def is_enabled_for(self, props: Dict[str, str], rollout_percent: Optional[int] = None) -> bool:
        """
        True if enabled AND (no rules OR some rule matches props) AND rollout_percent <= rule.percent_rollout.
        rollout_percent=None → treat as 100 (only 100% rules pass).
        """
        if not self.enabled:
            return False
        if not self.rules:
            return True
        eff = 100 if rollout_percent is None else max(0, min(100, rollout_percent))
        for r in self.rules:
            if all(props.get(k) == v for k, v in r.match_props.items()):  # match all required props
                if eff <= r.percent_rollout:
                    return True
        return False


# =========================
# (Optional) Minimal Smoke Demos
# =========================
if __name__ == "__main__":
    # Arrays & Searches
    print("binary_search:", binary_search([-1, 0, 3, 5, 9, 12], 9))                 # 4
    print("search_rotated:", search_rotated([4, 5, 6, 7, 0, 1, 2], 0))              # 4
    print("koko_min_eating_speed:", koko_min_eating_speed([3, 6, 7, 11], 8))        # 4
    print("ship_within_days:", ship_within_days([1, 2, 3, 1, 1], 4))                 # 3

    # Prefix sums
    print("subarray_sum_equals_k:", subarray_sum_equals_k([1, 1, 1], 2))             # 2

    # Linked lists
    a = ll_from_list([1, 2, 4]); b = ll_from_list([1, 3, 4])
    print("merge_two_lists:", ll_to_list(merge_two_lists(a, b)))                     # [1,1,2,3,4,4]
    print("reverse_list:", ll_to_list(reverse_list(ll_from_list([1, 2, 3]))))        # [3,2,1]

    # Trees
    t = TreeNode(1, TreeNode(2, TreeNode(4)), TreeNode(3))
    print("max_depth_dfs/bfs:", max_depth_dfs(t), max_depth_bfs(t))                  # 3 3
    t2 = TreeNode(3, TreeNode(9), TreeNode(20, TreeNode(15), TreeNode(7)))
    print("level_order:", level_order(t2))                                            # [[3],[9,20],[15,7]]

    # Graphs
    g = [["1","1","0","0","0"],
         ["1","1","0","0","0"],
         ["0","0","1","0","0"],
         ["0","0","0","1","1"]]
    print("num_islands:", num_islands([row[:] for row in g]))                        # 3
    img = [[1,1,1],[1,1,0],[1,0,1]]
    print("flood_fill:", flood_fill([row[:] for row in img], 1, 1, 2))               # [[2,2,2],[2,2,0],[2,0,1]]

    # Heaps + Intervals
    print("top_k_frequent:", top_k_frequent([1, 1, 1, 2, 2, 3], 2))                  # [1,2]
    print("bucket_top_k:", bucket_top_k([1, 1, 1, 2, 2, 3], 2))                      # [1,2]
    print("merge_intervals:", merge_intervals([[1,3],[2,6],[8,10],[15,18]]))         # [[1,6],[8,10],[15,18]]

    # Dataclasses
    r1 = Rule("IN 25%", 25, {"region": "IN"}); r2 = Rule("US 100%", 100, {"region": "US"})
    flag = Flag("homepage", True, [r1, r2])
    print("flag US@5%:", flag.is_enabled_for({"region": "US"}, 5))                   # True
    print("flag IN@30%:", flag.is_enabled_for({"region": "IN"}, 30))                 # False
    print("asdict(flag):", asdict(flag))                                             # nested dict
    print("replace(flag):", replace(flag, enabled=False))                             # copy with change