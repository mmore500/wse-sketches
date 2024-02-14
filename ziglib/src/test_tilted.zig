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

test "test_get_hanoi_num_reservations8" {
    const surface_size: u32 = 8;
    for (0..(1 << 8)) |rank_| {
        const rank: u32 = @intCast(rank_);
        const hnr = tilted.get_hanoi_num_reservations(rank, surface_size);
        const gnr = tilted.get_global_num_reservations(rank, surface_size);
        try std.testing.expect(hnr == gnr or hnr == gnr * 2);
    }

    for (0..7) |rank_| {
        const rank: u32 = @intCast(rank_);
        try std.testing.expect(hanoi.get_max_hanoi_value_through_index(rank) <= 2);
        try std.testing.expectEqual(@as(u32, 4), tilted.get_hanoi_num_reservations(rank, surface_size));
    }

    for (7..15) |rank_| {
        const rank: u32 = @intCast(rank_);
        try std.testing.expect(hanoi.get_max_hanoi_value_through_index(rank) == 3);
        try std.testing.expectEqual(@as(u32, 2), tilted.get_hanoi_num_reservations(rank, surface_size));
    }

    for (15..31) |rank_| {
        const rank: u32 = @intCast(rank_);
        try std.testing.expect(hanoi.get_max_hanoi_value_through_index(rank) == 4);
        if (hanoi.get_hanoi_value_at_index(rank) == 1) {
            try std.testing.expectEqual(@as(u32, 2), tilted.get_hanoi_num_reservations(rank, surface_size));
        } else if (hanoi.get_hanoi_value_at_index(rank) == 2) {
            try std.testing.expectEqual(@as(u32, 2), tilted.get_hanoi_num_reservations(rank, surface_size));
        } else {
            try std.testing.expectEqual(@as(u32, 1), tilted.get_hanoi_num_reservations(rank, surface_size));
        }
    }

    for (31..63) |rank_| {
        const rank: u32 = @intCast(rank_);
        try std.testing.expect(hanoi.get_max_hanoi_value_through_index(rank) == 5);
        if (hanoi.get_hanoi_value_at_index(rank) == 2) {
            try std.testing.expectEqual(@as(u32, 2), tilted.get_hanoi_num_reservations(rank, surface_size));
        } else {
            try std.testing.expectEqual(@as(u32, 1), tilted.get_hanoi_num_reservations(rank, surface_size));
        }
    }

    for (64..127) |rank_| {
        const rank: u32 = @intCast(rank_);
        try std.testing.expect(hanoi.get_max_hanoi_value_through_index(rank) == 6);
        try std.testing.expectEqual(@as(u32, 1), tilted.get_hanoi_num_reservations(rank, surface_size));
    }
}

test "test_get_hanoi_num_reservations16" {
    const surface_size: u32 = 16;
    for (0..(1 << 16)) |rank_| {
        const rank: u32 = @intCast(rank_);
        const hnr = tilted.get_hanoi_num_reservations(rank, surface_size);
        const gnr = tilted.get_global_num_reservations(rank, surface_size);
        try std.testing.expect(hnr == gnr or hnr == gnr * 2);
    }
}

test "test_get_hanoi_num_reservations32" {
    const surface_size: u32 = 32;
    for (0..(1 << 16)) |rank_| {
        const rank: u32 = @intCast(rank_);
        const hnr = tilted.get_hanoi_num_reservations(rank, surface_size);
        const gnr = tilted.get_global_num_reservations(rank, surface_size);
        try std.testing.expect(hnr == gnr or hnr == gnr * 2);
    }

    var prng = std.rand.DefaultPrng.init(1234);
    var random = prng.random();
    var rank: u32 = undefined;
    for (0..10000) |_| {
        rank = random.int(u32);
        const hnr = tilted.get_hanoi_num_reservations(rank, surface_size);
        const gnr = tilted.get_global_num_reservations(rank, surface_size);
        try std.testing.expect(hnr == gnr or hnr == gnr * 2);
    }
}

test "test_get_hanoi_num_reservations64" {
    const surface_size: u32 = 64;
    for (0..(1 << 16)) |rank_| {
        const rank: u32 = @intCast(rank_);
        const hnr = tilted.get_hanoi_num_reservations(rank, surface_size);
        const gnr = tilted.get_global_num_reservations(rank, surface_size);
        try std.testing.expect(hnr == gnr or hnr == gnr * 2);
    }

    var prng = std.rand.DefaultPrng.init(1234);
    var random = prng.random();
    var rank: u32 = undefined;
    for (0..10000) |_| {
        rank = random.int(u32); // library only supports 32-bit integers
        const hnr = tilted.get_hanoi_num_reservations(rank, surface_size);
        const gnr = tilted.get_global_num_reservations(rank, surface_size);
        try std.testing.expect(hnr == gnr or hnr == gnr * 2);
    }
}

test "test_get_reservation_position_logical4" {
    try std.testing.expectEqual(tilted.get_reservation_position_logical(0, 4), 0);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(1, 4), 3);
}

test "test_get_reservation_position_logical8" {
    try std.testing.expectEqual(tilted.get_reservation_position_logical(0, 8), 0);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(1, 8), 5);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(2, 8), 4);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(3, 8), 7);
}

test "test_get_reservation_position_logical16" {
    try std.testing.expectEqual(tilted.get_reservation_position_logical(0, 16), 0);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(1, 16), 9);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(2, 16), 6);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(3, 16), 13);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(4, 16), 5);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(5, 16), 8);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(6, 16), 12);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(7, 16), 15);
}

test "test_get_reservation_position_logical32" {
    try std.testing.expectEqual(tilted.get_reservation_position_logical(0, 32), 0);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(1, 32), 17);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(2, 32), 10);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(3, 32), 25);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(4, 32), 7);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(5, 32), 14);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(6, 32), 22);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(7, 32), 29);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(8, 32), 6);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(9, 32), 9);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(10, 32), 13);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(11, 32), 16);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(12, 32), 21);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(13, 32), 24);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(14, 32), 28);
    try std.testing.expectEqual(tilted.get_reservation_position_logical(15, 32), 31);
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

test "test_pick_deposition_site8" {
    const expected8 = [_]u32{ 0, 1, 5, 2, 4, 6, 7, 3, 0, 1, 5, 7, 0, 6, 5, 4, 0, 1, 0, 2, 0, 6, 0, 3, 0, 1, 0, 7, 0, 6, 0, 5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 7, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 7, 0, 1, 0, 6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 7, 0 };
    const surfaceSize: u32 = 8;

    for (0..expected8.len) |rank| {
        const expected = expected8[rank];
        const actual = tilted.pick_deposition_site(@intCast(rank), surfaceSize);
        try std.testing.expectEqual(expected, actual);
    }
}

test "test_pick_deposition_site16" {
    const expected16 = [_]u32{ 0, 1, 9, 2, 6, 10, 13, 3, 5, 7, 8, 11, 12, 14, 15, 4, 0, 1, 9, 8, 6, 10, 13, 12, 0, 7, 9, 15, 6, 14, 13, 5, 0, 1, 9, 2 }; // Note: Your provided list was cut off, make sure to complete it.
    const surfaceSize: u32 = 16;

    for (0..expected16.len) |rank| {
        const expected = expected16[rank];
        const actual = tilted.pick_deposition_site(@intCast(rank), surfaceSize);
        try std.testing.expectEqual(expected, actual);
    }
}
