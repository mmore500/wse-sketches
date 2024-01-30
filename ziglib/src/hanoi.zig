const std = @import("std");

/// Returns the value at a given index in the zero-indexed, zero-based Hanoi
/// sequence.
///
/// This sequence is equivalent to the Hanoi sequence
/// ([A001511](https://oeis.org/A00151)) with all values decreased by one, and
/// is listed as [A007814](https://oeis.org/A007814) in the Online Encyclopedia
/// of Integer Sequences. The function computes the value in constant time
/// using a zero-based indexing convention.
pub fn getHanoiValueAtIndex(n: u32) u32 {
    return @ctz(n + 1);
}

test "test_getHanoiValueAtIndex" {
    const A001511 = [_]u32{
        1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 5, 1, 2, 1, 3, 1, 2, 1, 4,
        1, 2, 1, 3, 1, 2, 1, 6, 1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 5,
        1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 7, 1, 2, 1, 3, 1, 2, 1, 4,
        1, 2, 1, 3, 1, 2, 1, 5, 1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 6,
        1, 2, 1, 3, 1, 2, 1, 4, 1,
    };
    for (A001511, 0..) |v, i| {
        try std.testing.expectEqual(v - 1, getHanoiValueAtIndex(@intCast(i)));
    }
}
