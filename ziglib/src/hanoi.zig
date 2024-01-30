const std = @import("std");

/// Returns the value at a given index in the zero-indexed, zero-based Hanoi
/// sequence.
///
/// This sequence is equivalent to the Hanoi sequence
/// ([A001511](https://oeis.org/A00151)) with all values decreased by one, and
/// is listed as [A007814](https://oeis.org/A007814) in the Online Encyclopedia
/// of Integer Sequences. The function computes the value in constant time
/// using a zero-based indexing convention.
pub fn get_hanoi_value_at_index(n: u32) u32 {
    return @ctz(n + 1);
}

test "test_get_hanoi_value_at_index" {
    const A001511 = [_]u32{
        1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 5, 1, 2, 1, 3, 1, 2, 1, 4,
        1, 2, 1, 3, 1, 2, 1, 6, 1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 5,
        1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 7, 1, 2, 1, 3, 1, 2, 1, 4,
        1, 2, 1, 3, 1, 2, 1, 5, 1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 6,
        1, 2, 1, 3, 1, 2, 1, 4, 1,
    };
    for (A001511, 0..) |v, i| {
        try std.testing.expectEqual(
            v - 1,
            get_hanoi_value_at_index(@intCast(i)),
        );
    }
}

/// How many times has the hanoi value at index `n` already been encountered?
///
/// Assumes zero-indexing convention. See `get_hanoi_value_at_index` for notes
/// on zero-based variant of Hanoi sequence used.
pub fn get_hanoi_value_incidence_at_index(n: u32) u32 {
    // equiv to n // 2 ** (get_hanoi_value_at_index(n) + 1)
    return n >> @intCast(get_hanoi_value_at_index(n) + 1);
}

test "get_hanoi_value_incidence_at_index" {
    var hanoi_values: [100]u32 = undefined;
    for (0..100) |i| {
        hanoi_values[i] = get_hanoi_value_at_index(@intCast(i));
    }

    for (0..100) |n| {
        var count: u32 = 0;
        for (0..n) |j| {
            if (hanoi_values[j] == hanoi_values[n]) {
                count += 1;
            }
        }
        std.debug.assert(count == get_hanoi_value_incidence_at_index(
            @intCast(n),
        ));
    }
}
