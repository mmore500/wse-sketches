const tilted = @import("tilted.zig");
const std = @import("std");

test "test_get_reservation_position_physical" {
    // Test for surface size 4
    const expected4 = [_]i32{ 0, 3 };
    for (expected4, 0..) |value, i| {
        const j: i32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 4);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 8
    const expected8 = [_]i32{ 0, 4, 5, 7 };
    for (expected8, 0..) |value, i| {
        const j: i32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 8);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 16
    const expected16 = [_]i32{ 0, 5, 6, 8, 9, 12, 13, 15 };
    for (expected16, 0..) |value, i| {
        const j: i32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 16);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 32
    const expected32 = [_]i32{ 0, 6, 7, 9, 10, 13, 14, 16, 17, 21, 22, 24, 25, 28, 29, 31 };
    for (expected32, 0..) |value, i| {
        const j: i32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 32);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 64 with specific checks
    try std.testing.expectEqual(tilted.get_reservation_position_physical(0, 64), 0);
    try std.testing.expectEqual(tilted.get_reservation_position_physical(16, 64), 33);
    try std.testing.expectEqual(tilted.get_reservation_position_physical(31, 64), 63);

    // Test all values for surface size 64 are increasing
    var prevResult: i32 = tilted.get_reservation_position_physical(0, 64) - 1; // Initialize to one less than the first expected result
    for (0..32) |i| {
        const j: i32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 64);
        try std.testing.expect(result > prevResult);
        prevResult = result;
    }
}
