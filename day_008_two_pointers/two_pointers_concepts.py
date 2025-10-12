# TWO POINTERS PATTERN

# Core Idea: A highly efficient technique (usually O(n) time, O(1) space) that uses two pointers
# to iterate through an array or string, avoiding the need for costly O(n^2) nested loops.

# PATTERN 1: Converging Pointers (from opposite ends)
# - DESCRIPTION: One pointer starts at the beginning (`left = 0`), the other at the end (`right = len(arr) - 1`).
# - MOVEMENT: The pointers move towards each other (`left` increases, `right` decreases).
# - TYPICAL USE CASES:
#   1. Finding a pair in a SORTED array that meets a certain condition (e.g., Two Sum II).
#   2. Problems involving palindromes.
# - KEY PROBLEM: LeetCode #125 - Valid Palindrome.

# PATTERN 2: Fast & Slow Pointers (moving in the same direction at different speeds)
# - DESCRIPTION: Both pointers start at the beginning. One (`slow`) moves one step at a time,
#   the other (`fast`) moves two or more steps at a time.
# - MOVEMENT: `slow = slow.next`, `fast = fast.next.next`.
# - TYPICAL USE CASES:
#   1. Detecting cycles in a Linked List (if they meet, there's a cycle).
#   2. Finding the middle of a Linked List (when `fast` reaches the end, `slow` is in the middle).
#   3. Problems involving array element removal or ordering.

# Add any other patterns or insights you gather from the video.