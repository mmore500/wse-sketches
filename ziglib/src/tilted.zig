const std = @import("std");

const hanoi = @import("hanoi.zig");
const oeis = @import("oeis.zig");
const pylib = @import("pylib.zig");

pub fn get_global_num_reservations_at_epoch(epoch: u32, surfaceSize: u32) u32 {
    // must be even power of 2
    std.debug.assert(@popCount(surfaceSize) == 1);
    return surfaceSize >> (1 + epoch);
}

pub fn get_hanoi_value_index_offset(value: u32) u32 {
    return (1 << value) - 1; // Equivalent to 2**value - 1 in Python
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
