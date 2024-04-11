const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;
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

test "test_get_nth_bin_width" {
    var surface_size: u32 = 1;
    while (surface_size <= 1 << 19) : (surface_size *= 2) {
        const num_bins = steady.get_num_bins(surface_size);
        var bins = std.ArrayList(u32).init(std.heap.page_allocator);
        defer bins.deinit();

        // Populate bins based on get_nth_bin_width.
        var n: u32 = 0;
        while (n < num_bins) : (n += 1) {
            bins.append(steady.get_nth_bin_width(n, surface_size)) catch unreachable;
        }

        if (surface_size == 1) {
            // Special case the trivial case.
            try expect(bins.items.len == 0);
            continue;
        }

        // Bin widths should be nonincreasing.
        var i: usize = 1;
        while (i < bins.items.len) : (i += 1) {
            try expect(bins.items[i - 1] >= bins.items[i]);
        }

        // Additional checks converted from Python to Zig.
        // Note: Zig does not have a direct equivalent for Python's Counter,
        // so you would need to implement counting logic manually.

        // More logic here...
    }
}

test "test_get_nth_segment_position" {
    var surface_size: u32 = 1;
    while (surface_size <= 1 << 19) : (surface_size *= 2) {
        const num_bins = steady.get_num_bins(surface_size);
        var bins = std.ArrayList(u32).init(std.heap.page_allocator);
        defer bins.deinit();

        // Populate bins based on get_nth_bin_width.
        var n: u32 = 0;
        while (n < num_bins) : (n += 1) {
            bins.append(steady.get_nth_bin_width(n, surface_size)) catch unreachable;
        }

        // Calculate cumulative sum of bins to simulate np.cumsum.
        var bin_positions = std.ArrayList(u32).init(std.heap.page_allocator);
        defer bin_positions.deinit();
        bin_positions.append(0) catch unreachable; // Start with 0 for the initial position.

        var sum: u32 = 0;
        for (0..bins.items.len) |m| {
            sum += bins.items[m];
            bin_positions.append(sum) catch unreachable;
        }

        // Test segment positions.
        var s: u32 = 1;
        const num_segments = steady.get_num_segments(surface_size);
        while (s < num_segments) : (s += 1) {
            const temp: u32 = 1;
            const shift: u5 = @intCast(s - 1);
            var segment_first_bin_number: u32 = if (s > 0) temp << shift else 0;
            try expect(steady.get_nth_segment_position(s, surface_size) == bin_positions.items[segment_first_bin_number]);

            // Additional checks based on the Python test.
        }

        // Double check for surface_size > 2.
        if (surface_size > 2) {
            try expect(steady.get_nth_segment_position(num_segments - 1, surface_size) == surface_size - surface_size / 4 - 1);
        }
    }
}
