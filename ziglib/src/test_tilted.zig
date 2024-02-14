const std = @import("std");

const hanoi = @import("hanoi.zig");
const tilted = @import("tilted.zig");

fn gge_expected(rank: u32, surface_size: u32) u32 {
    if (surface_size == 8) {
        if (rank < hanoi.get_hanoi_value_index_offset(3)) return 0;
        if (rank < hanoi.get_hanoi_value_index_offset(4)) return 1;
        return 2;
    } else if (surface_size == 16) {
        if (rank < hanoi.get_hanoi_value_index_offset(4)) return 0;
        if (rank < hanoi.get_hanoi_value_index_offset(5)) return 1;
        if (rank < hanoi.get_hanoi_value_index_offset(8)) return 2;
        return 3;
    } else if (surface_size == 32) {
        if (rank < hanoi.get_hanoi_value_index_offset(5)) return 0;
        if (rank < hanoi.get_hanoi_value_index_offset(6)) return 1;
        if (rank < hanoi.get_hanoi_value_index_offset(9)) return 2;
        if (rank < hanoi.get_hanoi_value_index_offset(16)) return 3;
        return 4;
    } else if (surface_size == 64) {
        if (rank < hanoi.get_hanoi_value_index_offset(6)) return 0;
        if (rank < hanoi.get_hanoi_value_index_offset(7)) return 1;
        if (rank < hanoi.get_hanoi_value_index_offset(10)) return 2;
        if (rank < hanoi.get_hanoi_value_index_offset(17)) return 3;
        if (rank < hanoi.get_hanoi_value_index_offset(32)) return 4;
        return 5;
    } else {
        @panic("Unsupported surface size");
    }
}

test "test_get_global_epoch for various surface sizes" {
    const surface_sizes = [_]u32{8};

    for (surface_sizes) |size| {
        // Use a smaller range for testing to avoid excessive test durations
        const lb = @as(u32, 0);
        const ub = @min(@as(u32, 4096), @as(u32, 1) << @intCast(size));
        for (lb..ub) |rank_| {
            const rank: u32 = @intCast(rank_);
            const expected_epoch = gge_expected(rank, size);
            const actual_epoch = tilted.get_global_epoch(rank, size);
            try std.testing.expectEqual(expected_epoch, actual_epoch);
        }
    }
}

fn ggnr_expected(rank: u32, surface_size: u32) u32 {
    if (surface_size == 8) {
        if (rank < hanoi.get_hanoi_value_index_offset(3)) return 4;
        if (rank < hanoi.get_hanoi_value_index_offset(4)) return 2;
        return 1;
    } else if (surface_size == 16) {
        if (rank < hanoi.get_hanoi_value_index_offset(4)) return 8;
        if (rank < hanoi.get_hanoi_value_index_offset(5)) return 4;
        if (rank < hanoi.get_hanoi_value_index_offset(8)) return 2;
        return 1;
    } else if (surface_size == 32) {
        if (rank < hanoi.get_hanoi_value_index_offset(5)) return 16;
        if (rank < hanoi.get_hanoi_value_index_offset(6)) return 8;
        if (rank < hanoi.get_hanoi_value_index_offset(9)) return 4;
        if (rank < hanoi.get_hanoi_value_index_offset(16)) return 2;
        return 1;
    } else if (surface_size == 64) {
        if (rank < hanoi.get_hanoi_value_index_offset(6)) return 32;
        if (rank < hanoi.get_hanoi_value_index_offset(7)) return 16;
        if (rank < hanoi.get_hanoi_value_index_offset(10)) return 8;
        if (rank < hanoi.get_hanoi_value_index_offset(17)) return 4;
        if (rank < hanoi.get_hanoi_value_index_offset(32)) return 2;
        return 1;
    } else {
        @panic("Unsupported surface size");
    }
}

test "test_get_global_num_reservations for various surface sizes" {
    const surface_sizes = [_]u32{8};

    for (surface_sizes) |size| {
        // Use a smaller range for testing to avoid excessive test durations
        const lb = @as(u32, 0);
        const ub = @min(@as(u32, 4096), @as(u32, 1) << @intCast(size));
        for (lb..ub) |rank_| {
            const rank: u32 = @intCast(rank_);
            const expected = ggnr_expected(rank, size);
            const actual = tilted.get_global_num_reservations(rank, size);
            try std.testing.expectEqual(expected, actual);
        }
    }
}

test "test_get_global_num_reservations_at_epoch for various surface sizes" {
    const surface_sizes = [_]u32{8};

    for (surface_sizes) |size| {
        // Use a smaller range for testing to avoid excessive test durations
        const lb = @as(u32, 0);
        const ub = @min(@as(u32, 4096), @as(u32, 1) << @intCast(size));
        for (lb..ub) |rank_| {
            const rank: u32 = @intCast(rank_);
            const epoch: u32 = tilted.get_global_epoch(rank, size);
            const expected = ggnr_expected(rank, size);
            const actual = tilted.get_global_num_reservations_at_epoch(epoch, size);
            try std.testing.expectEqual(expected, actual);
        }
    }
}

test "test_get_reservation_position_physical" {
    // Test for surface size 4
    const expected4 = [_]u32{ 0, 3 };
    for (expected4, 0..) |value, i| {
        const j: u32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 4);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 8
    const expected8 = [_]u32{ 0, 4, 5, 7 };
    for (expected8, 0..) |value, i| {
        const j: u32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 8);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 16
    const expected16 = [_]u32{ 0, 5, 6, 8, 9, 12, 13, 15 };
    for (expected16, 0..) |value, i| {
        const j: u32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 16);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 32
    const expected32 = [_]u32{ 0, 6, 7, 9, 10, 13, 14, 16, 17, 21, 22, 24, 25, 28, 29, 31 };
    for (expected32, 0..) |value, i| {
        const j: u32 = @intCast(i);
        const result = tilted.get_reservation_position_physical(j, 32);
        try std.testing.expectEqual(value, result);
    }

    // Test for surface size 64 with specific checks
    try std.testing.expectEqual(tilted.get_reservation_position_physical(0, 64), 0);
    try std.testing.expectEqual(tilted.get_reservation_position_physical(16, 64), 33);
    try std.testing.expectEqual(tilted.get_reservation_position_physical(31, 64), 63);

    // Test all values for surface size 64 are increasing
    const rpp: i32 = @intCast(tilted.get_reservation_position_physical(0, 64));
    // Initialize to one less than the first expected result
    var prevResult: i32 = rpp - 1;
    for (0..32) |i| {
        const j: u32 = @intCast(i);
        const result: i32 = @intCast(tilted.get_reservation_position_physical(j, 64));
        try std.testing.expect(result > prevResult);
        prevResult = result;
    }
}
