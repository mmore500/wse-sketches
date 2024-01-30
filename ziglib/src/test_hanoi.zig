const std = @import("std");

const hanoi = @import("hanoi.zig");

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
            hanoi.get_hanoi_value_at_index(@intCast(i)),
        );
    }
}

test "get_hanoi_value_incidence_at_index" {
    var hanoi_values: [100]u32 = undefined;
    for (0..100) |i| {
        hanoi_values[i] = hanoi.get_hanoi_value_at_index(@intCast(i));
    }

    for (0..100) |n| {
        var count: u32 = 0;
        for (0..n) |j| {
            if (hanoi_values[j] == hanoi_values[n]) {
                count += 1;
            }
        }
        std.debug.assert(count == hanoi.get_hanoi_value_incidence_at_index(
            @intCast(n),
        ));
    }
}
