const std = @import("std");

const hanoi = @import("hanoi.zig");
const oeis = @import("oeis.zig");
const pylib = @import("pylib.zig");

pub fn get_global_num_reservations_at_epoch(epoch: u32, surfaceSize: u32) u32 {
    // Zig does not have a direct bit_count method, so you would need to implement or use an equivalent.
    std.debug.assert(std.bitops.popCount(u32(surfaceSize)) == 1); // Assuming surfaceSize is positive and fits in u32
    return surfaceSize >> (1 + epoch);
}

pub fn get_hanoi_value_index_offset(value: u32) u32 {
    return (1 << value) - 1; // Equivalent to 2**value - 1 in Python
}

pub fn get_reservation_position_physical(reservation: u32, surfaceSize: u32) u32 {
    // Assert surfaceSize is a power of 2
    std.debug.assert(surfaceSize & (surfaceSize - 1) == 0);
    // Assert reservation is within valid range
    std.debug.assert(0 <= reservation and (reservation < @divExact(surfaceSize, 2) or surfaceSize <= 2));

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
