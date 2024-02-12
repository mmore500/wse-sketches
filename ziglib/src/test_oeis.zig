const std = @import("std");
const oeis = @import("oeis.zig"); // Adjust import path as necessary

test "test_get_a000295_value_at_index" {
    // The expected values from the OEIS sequence A000295, starting from index 1 (skipping zeroth element)
    const expectedValues = &[_]i64{
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
        32752,
        65519,
        131054,
        262125,
        524268,
        1048555,
        2097130,
        4194281,
        8388584,
        16777191,
        33554406,
        67108837,
        134217700,
        268435427,
        536870882,
        1073741793,
        2147483616,
        4294967263,
        8589934558,
    };

    // Iterate over each expected value and compare it to the computed value
    for (expectedValues, 0..) |value, index| {
        const computedValue = oeis.get_a000295_value_at_index(@as(i64, @intCast(index)));
        try std.testing.expectEqual(@as(i64, @intCast(computedValue)), value);
    }
}

test "test_get_a000295_index_of_value" {
    // First part: Specific expected index results for values 0 through 14
    const expectedIndices = [_]i32{
        0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3,
    };
    for (expectedIndices, 0..) |expected, i| {
        const j: i32 = @intCast(i);
        const n = oeis.get_a000295_index_of_value(j);
        try std.testing.expectEqual(expected, n);
    }

    // Second part: General condition for values 0 through 399
    for (0..400) |i| {
        const j: i32 = @intCast(i);
        const n = oeis.get_a000295_index_of_value(j);
        const lb = oeis.get_a000295_value_at_index(n);
        const ub = oeis.get_a000295_value_at_index(n + 1);
        try std.testing.expect(lb <= i and i < ub);
    }
}
