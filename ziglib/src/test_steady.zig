const std = @import("std");
const expectEqual = std.testing.expectEqual;
const steady = @import("steady.zig");

test "test_get_num_bins" {
    try expectEqual(steady.get_num_bins(1), 0);
    try expectEqual(steady.get_num_bins(2), 1);
    try expectEqual(steady.get_num_bins(4), 2);
    try expectEqual(steady.get_num_bins(8), 4);
    try expectEqual(steady.get_num_bins(16), 8);
}

test "test_get_num_segments" {
    try expectEqual(steady.get_num_segments(1), 0);
    try expectEqual(steady.get_num_segments(2), 1);
    try expectEqual(steady.get_num_segments(4), 2);
    try expectEqual(steady.get_num_segments(8), 3);
    try expectEqual(steady.get_num_segments(16), 4);
    try expectEqual(steady.get_num_segments(32), 5);
    try expectEqual(steady.get_num_segments(64), 6);
    try expectEqual(steady.get_num_segments(128), 7);
    try expectEqual(steady.get_num_segments(256), 8);
    try expectEqual(steady.get_num_segments(512), 9);
    try expectEqual(steady.get_num_segments(1024), 10);
    try expectEqual(steady.get_num_segments(2048), 11);
}
