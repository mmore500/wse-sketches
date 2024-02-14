const std = @import("std");

const hanoi = @import("hanoi.zig");
const longevity = @import("longevity.zig");
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

pub fn get_global_num_reservations(rank: u32, surfaceSize: u32) u32 {
    const epoch = get_global_epoch(rank, surfaceSize);
    return get_global_num_reservations_at_epoch(epoch, surfaceSize);
}

pub fn get_global_num_reservations_at_epoch(epoch: u32, surfaceSize: u32) u32 {
    // must be even power of 2
    std.debug.assert(@popCount(surfaceSize) == 1);
    const shift: u5 = @intCast(1 + epoch);
    return surfaceSize >> shift;
}

pub fn get_hanoi_num_reservations(rank: u32, surfaceSize: u32) u32 {
    const epoch = get_global_epoch(rank, surfaceSize);
    const grc = get_global_num_reservations(rank, surfaceSize);

    if (epoch == 0) {
        return grc;
    }

    const shift1: u5 = @intCast(epoch);
    const maxUninvaded: u32 = (@as(u32, 1) << shift1) - 2; // 0, 2, 6, 14, ...
    std.debug.assert(maxUninvaded >= 0);

    const hanoiValue: u32 = hanoi.get_hanoi_value_at_index(rank);

    if (hanoiValue > maxUninvaded) {
        return grc;
    }

    const reservation0At = hanoi.get_max_hanoi_value_through_index(rank);
    std.debug.assert(epoch > 0);

    const shift2: u5 = @intCast(epoch - 1);
    const idx: u32 = @as(u32, 1) << shift2; // 1, 2, 4, 8, ...
    std.debug.assert(idx > 0);

    // -1 undoes correction for extra reservation 0 slot
    const reservation0Begin: u32 = get_reservation_position_physical(idx, surfaceSize) - 1;
    const reservation0Progress = reservation0At - reservation0Begin;

    if (hanoiValue <= reservation0Progress) {
        return grc;
    }

    return 2 * grc;
}

pub fn get_reservation_position_logical(reservation: u32, surfaceSize: u32) u32 {
    const numReservations = surfaceSize >> 1;
    const physicalReservation = longevity.get_longevity_mapped_position_of_index(reservation, numReservations);
    return get_reservation_position_physical(physicalReservation, surfaceSize);
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

pub fn pick_deposition_site(rank: u32, surfaceSize: u32) u32 {
    const numReservations = get_hanoi_num_reservations(rank, surfaceSize);

    const incidence = hanoi.get_hanoi_value_incidence_at_index(rank);
    const hanoiValue = hanoi.get_hanoi_value_at_index(rank);

    const reservation = pylib.fast_pow2_mod(incidence, numReservations);

    return get_reservation_position_logical(reservation, surfaceSize) + hanoiValue;
}
