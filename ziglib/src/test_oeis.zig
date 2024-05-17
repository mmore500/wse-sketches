const std = @import("std");
const oeis = @import("oeis.zig");

test "test_get_a000295_value_at_index" {
    const expectedValues = &[_]u32{
        0,
        1,
        4,
        11,
        26,
        57,
        120,
        247,
        502,
        1013,
        2036,
        4083,
        8178,
        16369,
    };

    for (expectedValues, 0..) |value, index| {
        const computedValue = oeis.get_a000295_value_at_index(@as(u32, @intCast(index)));
        try std.testing.expectEqual(@as(u32, @intCast(computedValue)), value);
    }
}

test "test_get_a000295_index_of_value" {
    const expectedIndices = [_]u32{
        0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3,
    };
    for (expectedIndices, 0..) |expected, i| {
        const j: u32 = @intCast(i);
        const n = oeis.get_a000295_index_of_value(j);
        try std.testing.expectEqual(expected, n);
    }

    for (0..400) |i| {
        const j: u32 = @intCast(i);
        const n = oeis.get_a000295_index_of_value(j);
        const lb = oeis.get_a000295_value_at_index(n);
        const ub = oeis.get_a000295_value_at_index(n + 1);
        try std.testing.expect(lb <= i and i < ub);
    }
}

test "test_get_a048881_value_at_index" {
    const expectedValues: []const u32 = &.{ 0, 0, 1, 0, 1, 1, 2, 0, 1, 1, 2, 1, 2, 2, 3, 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3 };

    for (expectedValues, 0..) |value, i| {
        const j: u32 = @intCast(i);
        const actualValue = oeis.get_a048881_value_at_index(j);
        try std.testing.expectEqual(value, actualValue);
    }
}

test "test_get_a083058_value_at_index" {
    const expected_sequence = [_]i32{
        1,  0,  1,  1,  2,  3,  4,  4,  5,  6,  7,  8,  9,  10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 26,
        27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 57,
        58, 59, 60, 61, 62, 63, 64, 65, 66,
    };
    for (1..74) |i| {
        const j: u32 = @intCast(i);
        try std.testing.expect(oeis.get_a083058_value_at_index(j) == expected_sequence[i - 1]);
    }
}

test "test_get_a083058_index_of_value" {
    for (1..1000) |value| {
        const i: u32 = @intCast(value);
        const index = oeis.get_a083058_index_of_value(i);
        try std.testing.expect(value == oeis.get_a083058_value_at_index(index)); // Value matches its index in the sequence
        try std.testing.expect(value != oeis.get_a083058_value_at_index(index - 1)); // Ensure previous index does not match the value
    }
}
