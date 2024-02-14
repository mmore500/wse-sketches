const std = @import("std");

const longevity = @import("longevity.zig");

test "test_get_longevity_offset_of_level" {
    // Test for level range 1 with total levels 1
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(0, 1), 0);

    // Test for level range 2 with total levels 2
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(0, 2), 0);
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(1, 2), 1);

    // Test for level range 3 with total levels 4
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(0, 4), 0);
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(1, 4), 2);
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(2, 4), 1);

    // Test for level range 4 with total levels 8
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(0, 8), 0);
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(1, 8), 4);
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(2, 8), 2);
    try std.testing.expectEqual(longevity.get_longevity_offset_of_level(3, 8), 1);
}

test "test_get_longevity_mapped_position_of_index1" {
    var results: [1]u32 = undefined;
    for (0..1) |index| {
        results[index] = longevity.get_longevity_mapped_position_of_index(@intCast(index), 1);
    }
    std.debug.assert(std.mem.eql(u32, &results, &[_]u32{0}));

    var target: [1]u32 = undefined;
    for (0..1) |index| {
        const mapped_position = longevity.get_longevity_mapped_position_of_index(@intCast(index), 1);
        target[mapped_position] = @intCast(index);
    }
    std.debug.assert(std.mem.eql(u32, &target, &[_]u32{0}));
}

test "test_get_longevity_mapped_position_of_index2" {
    var results: [2]u32 = undefined;
    for (0..2) |index| {
        results[index] = longevity.get_longevity_mapped_position_of_index(@intCast(index), 2);
    }
    std.debug.assert(results[0] == 0);
    std.debug.assert(results[1] == 1);

    var target: [2]u32 = undefined;
    for (0..2) |index| {
        const mapped_position = longevity.get_longevity_mapped_position_of_index(@intCast(index), 2);
        target[mapped_position] = @intCast(index);
    }
    std.debug.assert(target[0] == 0);
    std.debug.assert(target[1] == 1);
}

test "test_get_longevity_mapped_position_of_index4" {
    var results: [4]u32 = undefined;
    for (0..4) |index| {
        results[index] = longevity.get_longevity_mapped_position_of_index(@intCast(index), 4);
    }
    std.debug.assert(std.mem.eql(u32, &results, &[_]u32{ 0, 2, 1, 3 }));

    var target: [4]u32 = undefined;
    for (0..4) |index| {
        const mapped_position = longevity.get_longevity_mapped_position_of_index(@intCast(index), 4);
        target[mapped_position] = @intCast(index);
    }
    std.debug.assert(std.mem.eql(u32, &target, &[_]u32{ 0, 2, 1, 3 }));
}

test "test_get_longevity_mapped_position_of_index8" {
    var results: [8]u32 = undefined;
    for (0..8) |index| {
        results[index] = longevity.get_longevity_mapped_position_of_index(@intCast(index), 8);
    }
    std.debug.assert(std.mem.eql(u32, &results, &[_]u32{ 0, 4, 2, 6, 1, 3, 5, 7 }));

    var target: [8]u32 = undefined;
    for (0..8) |index| {
        const mapped_position = longevity.get_longevity_mapped_position_of_index(@intCast(index), 8);
        target[mapped_position] = @intCast(index);
    }
    std.debug.assert(std.mem.eql(u32, &target, &[_]u32{ 0, 4, 2, 5, 1, 6, 3, 7 }));
}

test "test_get_longevity_mapped_position_of_index16" {
    var results: [16]u32 = undefined;
    for (0..16) |index| {
        results[index] = longevity.get_longevity_mapped_position_of_index(@intCast(index), 16);
    }
    std.debug.assert(std.mem.eql(u32, &results, &[_]u32{ 0, 8, 4, 12, 2, 6, 10, 14, 1, 3, 5, 7, 9, 11, 13, 15 }));

    var target: [16]u32 = undefined;
    for (0..16) |index| {
        const mapped_position = longevity.get_longevity_mapped_position_of_index(@intCast(index), 16);
        target[mapped_position] = @intCast(index);
    }
    std.debug.assert(std.mem.eql(u32, &target, &[_]u32{ 0, 8, 4, 9, 2, 10, 5, 11, 1, 12, 6, 13, 3, 14, 7, 15 }));
}
