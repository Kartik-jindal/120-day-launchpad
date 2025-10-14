# 1. INITIALIZE:
#    - `left = 0` (The left edge of the window)
#    - `result = 0` (or `float('inf')`, or an empty string, depending on the goal)
#    - A data structure to track the state of the current window.
#      (e.g., a hash set for unique characters, a hash map for character counts).

# 2. EXPAND THE WINDOW:
#    - Use a `for` loop with the `right` pointer to iterate through the entire array/string.
#    - `for right in range(len(array)):`
#    - In each iteration, add the new element `array[right]` to your window's state.

# 3. CHECK VALIDITY AND SHRINK THE WINDOW:
#    - After adding the new element, check if the window's state is still valid.
#    - The "invalid" condition is the core of the problem (e.g., "contains duplicates", "sum > target").
#    - Use an inner `while` loop: `while window_is_invalid:`
#    - To shrink, remove the element at the left edge, `array[left]`, from your window's state.
#    - Then, advance the left pointer: `left += 1`.
#    - The `while` loop continues until the window becomes valid again.

# 4. UPDATE THE RESULT:
#    - Once the window is guaranteed to be valid, you can perform calculations.
#    - This is where you might update your `result` variable.
#    - Example: `result = max(result, right - left + 1)` to find the max length.

# 5. RETURN:
#    - After the main `for` loop finishes, `return result`.
