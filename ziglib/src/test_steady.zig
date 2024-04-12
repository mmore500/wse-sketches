const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;
const steady = @import("steady.zig");
const pylib = @import("pylib.zig");
const oeis = @import("oeis.zig");

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

        var n: u32 = 0;
        while (n < num_bins) : (n += 1) {
            bins.append(steady.get_nth_bin_width(n, surface_size)) catch unreachable;
        }

        if (surface_size == 1) {
            try expect(bins.items.len == 0);
            continue;
        }

        var i: usize = 1;
        while (i < bins.items.len) : (i += 1) {
            try expect(bins.items[i - 1] >= bins.items[i]);
        }
    }
}

test "test_get_nth_segment_position" {
    var surface_size: u32 = 1;
    while (surface_size <= 1 << 19) : (surface_size *= 2) {
        const num_bins = steady.get_num_bins(surface_size);
        var bins = std.ArrayList(u32).init(std.heap.page_allocator);
        defer bins.deinit();

        var n: u32 = 0;
        while (n < num_bins) : (n += 1) {
            bins.append(steady.get_nth_bin_width(n, surface_size)) catch unreachable;
        }

        var bin_positions = std.ArrayList(u32).init(std.heap.page_allocator);
        defer bin_positions.deinit();
        bin_positions.append(0) catch unreachable;

        var sum: u32 = 0;
        for (0..bins.items.len) |m| {
            sum += bins.items[m];
            bin_positions.append(sum) catch unreachable;
        }

        var s: u32 = 1;
        const num_segments = steady.get_num_segments(surface_size);
        while (s < num_segments) : (s += 1) {
            const temp: u32 = 1;
            const shift: u5 = @intCast(s - 1);
            var segment_first_bin_number: u32 = if (s > 0) temp << shift else 0;
            try expect(steady.get_nth_segment_position(s, surface_size) == bin_positions.items[segment_first_bin_number]);
        }

        if (surface_size > 2) {
            try expect(steady.get_nth_segment_position(num_segments - 1, surface_size) == surface_size - surface_size / 4 - 1);
        }
    }
}

test "test_get_nth_segment_bin_width" {
    try expect(steady.get_nth_segment_bin_width(0, 2) == 1);
    try expect(steady.get_nth_segment_bin_width(0, 4) == 2);
    try expect(steady.get_nth_segment_bin_width(1, 4) == 1);
    try expect(steady.get_nth_segment_bin_width(0, 8) == 3);
    try expect(steady.get_nth_segment_bin_width(1, 8) == 2);
    try expect(steady.get_nth_segment_bin_width(2, 8) == 1);
    try expect(steady.get_nth_segment_bin_width(0, 16) == 4);
    try expect(steady.get_nth_segment_bin_width(1, 16) == 3);
    try expect(steady.get_nth_segment_bin_width(2, 16) == 2);
    try expect(steady.get_nth_segment_bin_width(3, 16) == 1);
    try expect(steady.get_nth_segment_bin_width(0, 32) == 5);
    try expect(steady.get_nth_segment_bin_width(1, 32) == 4);
    try expect(steady.get_nth_segment_bin_width(2, 32) == 3);
    try expect(steady.get_nth_segment_bin_width(3, 32) == 2);
    try expect(steady.get_nth_segment_bin_width(4, 32) == 1);
}

test "test_get_nth_bin_position" {
    var surface_size: u32 = 1;
    while (surface_size <= 1 << 19) : (surface_size *= 2) {
        const num_bins = steady.get_num_bins(surface_size);
        var cumulative_positions = std.ArrayList(u32).init(std.heap.page_allocator);
        defer cumulative_positions.deinit();

        // Initialize the first position to 0 to match Python's [0, *np.cumsum(bins)].
        cumulative_positions.append(0) catch unreachable;

        // Compute cumulative positions from bin widths.
        var sum: u32 = 0;
        for (0..num_bins) |n| {
            const m: u32 = @intCast(n);
            const bin_width = steady.get_nth_bin_width(m, surface_size);
            sum += bin_width;
            cumulative_positions.append(sum) catch unreachable;
        }

        // Compare the expected positions with those returned by get_nth_bin_position.
        for (0..num_bins) |n| {
            const m: u32 = @intCast(n);
            const expected_position = cumulative_positions.items[n];
            const actual_position = steady.get_nth_bin_position(m, surface_size);
            try expect(expected_position == actual_position);
        }

        // Compare the last position with get_num_positions(surface_size).
        const last_position = steady.get_num_positions(surface_size);
        try expect(cumulative_positions.items[num_bins] == last_position);
    }
}

test "test_get_bin_width_at_position" {
    try std.testing.expect(steady.get_bin_width_at_position(2184, 16384) == 5);
    try std.testing.expect(steady.get_bin_width_at_position(9542, 32768) == 4);
    try std.testing.expect(steady.get_bin_width_at_position(14914, 32768) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(27131, 32768) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(29786, 32768) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(16932, 65536) == 4);
    try std.testing.expect(steady.get_bin_width_at_position(18352, 65536) == 4);
    try std.testing.expect(steady.get_bin_width_at_position(33795, 65536) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(33943, 65536) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(45661, 65536) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(52845, 65536) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(11643, 131072) == 6);
    try std.testing.expect(steady.get_bin_width_at_position(21202, 131072) == 5);
    try std.testing.expect(steady.get_bin_width_at_position(41000, 131072) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(55778, 131072) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(68512, 131072) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(80523, 131072) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(104749, 131072) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(105507, 131072) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(110597, 131072) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(111500, 131072) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(117544, 131072) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(5426, 262144) == 8);
    try std.testing.expect(steady.get_bin_width_at_position(14172, 262144) == 7);
    try std.testing.expect(steady.get_bin_width_at_position(32693, 262144) == 5);
    try std.testing.expect(steady.get_bin_width_at_position(50151, 262144) == 4);
    try std.testing.expect(steady.get_bin_width_at_position(60044, 262144) == 4);
    try std.testing.expect(steady.get_bin_width_at_position(62588, 262144) == 4);
    try std.testing.expect(steady.get_bin_width_at_position(83492, 262144) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(107417, 262144) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(115650, 262144) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(129639, 262144) == 3);
    try std.testing.expect(steady.get_bin_width_at_position(132871, 262144) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(145965, 262144) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(173432, 262144) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(180807, 262144) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(184007, 262144) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(189151, 262144) == 2);
    try std.testing.expect(steady.get_bin_width_at_position(202189, 262144) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(224463, 262144) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(248378, 262144) == 1);
    try std.testing.expect(steady.get_bin_width_at_position(253912, 262144) == 1);
}

test "test_get_bin_number_of_position" {
    var surface_size: u32 = 1;
    for (0..16) |_| {
        // Loop from 0 to surface_size - 1 for each power of 2 up to 2^15
        for (0..surface_size - 1) |position| {
            const pos: u32 = @intCast(position);
            const bin_number = steady.get_bin_number_of_position(pos, surface_size);
            const bin_position = steady.get_nth_bin_position(bin_number, surface_size);
            const bin_width = steady.get_nth_bin_width(bin_number, surface_size);

            // Ensure the position falls within the correct bin range
            try expect(bin_position <= pos);
            try expect(pos < bin_position + bin_width);
        }
        surface_size <<= 1; // Double surface_size to get next power of 2
    }
}
