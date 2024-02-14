const std = @import("std");

const hanoi = @import("hanoi.zig");
const oeis = @import("oeis.zig");
const pylib = @import("pylib.zig");

pub fn get_global_epoch(rank: u32, surfaceSize: u32) u32 {
    std.debug.assert(surfaceSize >= 4);
    // must be even power of 2
    std.debug.assert(@popCount(surfaceSize) == 1);

    const maxHanoi = hanoi.get_max_hanoi_value_through_index(rank);
    const baseHanoi = pylib.bit_length(surfaceSize) - 1;
    if (maxHanoi < baseHanoi) {
        return 0;
    } else {
        const diff = maxHanoi - baseHanoi;
        const operand = oeis.get_a000295_index_of_value(diff) + 1;
        const correction = pylib.bit_length(surfaceSize) - 2;
        return @min(operand, correction);
    }
}

pub fn get_global_num_reservations_at_epoch(epoch: u32, surfaceSize: u32) u32 {
    // must be even power of 2
    std.debug.assert(@popCount(surfaceSize) == 1);
    return surfaceSize >> (1 + epoch);
}

pub fn get_reservation_position_physical(reservation: u32, surfaceSize: u32) u32 {
    // must be even power of 2
    std.debug.assert(@popCount(surfaceSize) == 1);
    // Assert reservation is within valid range
    std.debug.assert(0 <= reservation);
    if (surfaceSize > 2) {
        std.debug.assert(reservation < @divExact(surfaceSize, 2));
    }

    if (reservation == 0) { // special case
        return 0;
    }

    const base = 2 * reservation;
    const lastReservation = (surfaceSize << 1) - 1;
    const offset = oeis.get_a048881_value_at_index(lastReservation - reservation);

    // Convert boolean to integer: true to 1, false to 0
    const layeringCorrection = @intFromBool(reservation != 0);

    return base + offset - 2 + layeringCorrection;
}
