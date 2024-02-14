const std = @import("std");

const hanoi = @import("hanoi.zig");
const longevity = @import("longevity.zig");
const oeis = @import("oeis.zig");
const pylib = @import("pylib.zig");

/// Return the reservation-halving epoch of the given rank.
///
/// Rank zero is at 0th epoch. Epochs count up with each reservation count
/// halving.
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

/// Return the number of global-level reservations at the given rank.
pub fn get_global_num_reservations(rank: u32, surfaceSize: u32) u32 {
    const epoch = get_global_epoch(rank, surfaceSize);
    return get_global_num_reservations_at_epoch(epoch, surfaceSize);
}

/// Helper method for get_global_num_reservations.
pub fn get_global_num_reservations_at_epoch(epoch: u32, surfaceSize: u32) u32 {
    // must be even power of 2
    std.debug.assert(@popCount(surfaceSize) == 1);
    const shift: u5 = @intCast(1 + epoch);
    return surfaceSize >> shift;
}

/// Return the number of reservations remaining at the given rank.
///
/// Either the current global-level reservation count, or double it if the
/// hanoi value is uninvaded.
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

/// Return the zeroth site of the given reservation, indexed in logical
/// order (persistence order).
pub fn get_reservation_position_logical(reservation: u32, surfaceSize: u32) u32 {
    const numReservations = surfaceSize >> 1;
    const physicalReservation = longevity.get_longevity_mapped_position_of_index(reservation, numReservations);
    return get_reservation_position_physical(physicalReservation, surfaceSize);
}

/// Return the zeroth site of the given reservation, indexed in physical
/// order at rank 0.
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

/// Pick the deposition site on a surface for a given rank.
///
/// This function calculates a deposition site based on the rank and the
/// surface size.
/// Parameters
/// ----------
/// rank : u32
///     The number of time steps elapsed.
/// surface_size : u32
///     The size of the surface on which deposition is to take place.
///     Must be even power of two.
/// Returns
/// -------
/// u32
///     Deposition site within surface.
pub fn pick_deposition_site(rank: u32, surfaceSize: u32) u32 {
    const numReservations = get_hanoi_num_reservations(rank, surfaceSize);

    const incidence = hanoi.get_hanoi_value_incidence_at_index(rank);
    const hanoiValue = hanoi.get_hanoi_value_at_index(rank);

    const reservation = pylib.fast_pow2_mod(incidence, numReservations);

    return get_reservation_position_logical(reservation, surfaceSize) + hanoiValue;
}
