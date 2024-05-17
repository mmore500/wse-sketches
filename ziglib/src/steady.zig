const std = @import("std");
const hanoi = @import("hanoi.zig");
const pylib = @import("pylib.zig");
const oeis = @import("oeis.zig");

pub fn get_num_positions(surfaceSize: u32) u32 {
    return surfaceSize - 1;
}

pub fn get_num_bins(surface_size: u32) u32 {
    return surface_size >> 1;
}

pub fn get_num_segments(surface_size: u32) u32 {
    const num_bins = get_num_bins(surface_size);
    if (num_bins == 0) return 0;
    return 32 - @clz(num_bins);
}

pub fn get_nth_bin_width(n: u32, surface_size: u32) u32 {
    return pylib.bit_count_immediate_zeros(n + (surface_size >> 1)) + 1;
}

pub fn get_nth_segment_position(n: u32, surface_size: u32) u32 {
    std.debug.assert(n >= 0);
    std.debug.assert(n < get_num_segments(surface_size));

    if (n == 0) return 0;

    const bit_count = ( // zig fmt: on
        32 // zig fmt: off
        - @clz(surface_size) // zig fmt: off
        - pylib.bit_count_immediate_zeros(surface_size) // zig fmt: off
    );
    std.debug.assert(bit_count == 1);
    const mbw_initial = @ctz(surface_size);
    std.debug.assert(mbw_initial == get_nth_bin_width(0, surface_size));

    var position: u32 = mbw_initial;
    const mbw: u32 = mbw_initial - 1;

    const lhs: u32 = 1;
    const m: u5 = @intCast(n - 1);

    position += (lhs << m) * mbw - mbw;
    position -= m * (lhs << m) + 2 - (lhs << (m + 1));
    return position;
}

pub fn get_nth_segment_bin_width(n: u32, surface_size: u32) u32 {
    std.debug.assert(n >= 0);
    std.debug.assert(n < get_num_segments(surface_size));

    const bit_length = pylib.bit_length(surface_size);
    std.debug.assert(bit_length - 1 == get_nth_bin_width(0, surface_size));

    return bit_length - n - 1;
}

pub fn get_nth_bin_position(n: u32, surface_size: u32) u32 {
    std.debug.assert(n >= 0);
    std.debug.assert(n < get_num_bins(surface_size));
    const bit_count = (
        32 // zig fmt: off
        - @clz(surface_size) // zig fmt: off
        - pylib.bit_count_immediate_zeros(surface_size) // zig fmt: off
    );
    std.debug.assert(bit_count == 1);

    if (n == 0) return 0;

    const completed_bins = pylib.bit_floor(n) - 1;

    std.debug.assert(
        32 // zig fmt: off
        - @clz(completed_bins) // zig fmt: off
        - pylib.bit_count_immediate_zeros(completed_bins)  // zig fmt: off
        == pylib.bit_length(completed_bins)  // zig fmt: off
    );
    const m = n - 1;
    std.debug.assert(completed_bins >= m / 2 and completed_bins <= m);
    // Include 0th segment.
    const completed_segments = 1 + ( // zig fmt: off
        32 // zig fmt: off
        - @clz(completed_bins) // zig fmt: off
        - pylib.bit_count_immediate_zeros(completed_bins) // zig fmt: off
    );

    var position = get_nth_segment_position(completed_segments, surface_size);

    const num_unhandled_bins = m - completed_bins;
    if (num_unhandled_bins > 0) {
        const unhandled_segment_bin_width = get_nth_segment_bin_width(completed_segments, surface_size);
        position += num_unhandled_bins * unhandled_segment_bin_width;
    }

    return position;
}

pub fn get_bin_width_at_position(position: u32, surfaceSize: u32) u32 {
    const numPositions = get_num_positions(surfaceSize);
    const positionFromEnd = numPositions - 1 - position;
    std.debug.assert(positionFromEnd < numPositions);

    if (position < get_nth_bin_width(0, surfaceSize)) {
        return get_nth_bin_width(0, surfaceSize);
    } else if (pylib.bit_length(positionFromEnd) < pylib.bit_length(surfaceSize) - 2) {
        return 1;
    } else if (pylib.bit_length(positionFromEnd) < pylib.bit_length(surfaceSize) - 1) {
        return 2;
    }

    const leadingOnes = pylib.bit_count_leading_ones(positionFromEnd);
    const a083058Index = oeis.get_a083058_index_of_value(leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(a083058Index) == leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(a083058Index - 1) < leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(a083058Index + 1) >= leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(a083058Index + 2) > leadingOnes);

    const ansatzSegmentFromEnd = a083058Index - 2;
    std.debug.assert(ansatzSegmentFromEnd < get_num_segments(surfaceSize));

    const ansatzSegment = get_num_segments(surfaceSize) - 1 - ansatzSegmentFromEnd;
    std.debug.assert(ansatzSegment < (get_num_segments(surfaceSize) - 1));

    var correction: u32 = @intFromBool( // zig fmt: off
        position < get_nth_segment_position(ansatzSegment, surfaceSize)
    );
    const eligibleExtraCorrection = leadingOnes == oeis.get_a083058_value_at_index(a083058Index + 1);
    if (eligibleExtraCorrection) {
        correction += @intFromBool(position < get_nth_segment_position(ansatzSegment - 1, surfaceSize));
    }

    return ansatzSegmentFromEnd + 1 + correction;
}

/// Assumes that surface_size is a power of two and that position is less than surface_size - 1
/// (excluding special-cased position zero).
pub fn get_bin_number_of_position(position: u32, surface_size: u32) u32 {
    const bit_count = 32 - @clz(surface_size) - pylib.bit_count_immediate_zeros(surface_size);
    std.debug.assert(bit_count == 1);
    std.debug.assert(position < surface_size - 1);

    const bin_width = get_bin_width_at_position(position, surface_size);
    const first_bin_width = get_nth_bin_width(0, surface_size);
    const bin_segment_number = first_bin_width - bin_width;

    if (bin_segment_number == 0) return 0;

    const one: u32 = 1;
    const shift: u5 = @intCast(first_bin_width - bin_width - 1);
    const bin_segment_first_bin_number = one << shift;
    std.debug.assert( // zig fmt: off
        get_nth_bin_width(bin_segment_first_bin_number, surface_size) // zig fmt: off
        == bin_width // zig fmt: off
    );
    std.debug.assert(bin_segment_first_bin_number != 0);
    std.debug.assert( // zig fmt: off
        get_nth_bin_width(bin_segment_first_bin_number - 1, surface_size) // zig fmt: off
        == bin_width + 1 // zig fmt: off
    );

    const bin_segment_first_bin_position = get_nth_bin_position(bin_segment_first_bin_number, surface_size);
    std.debug.assert(bin_segment_first_bin_position <= position);

    const bin_number_within_segment = (position - bin_segment_first_bin_position) / bin_width;
    return bin_segment_first_bin_number + bin_number_within_segment;
}


/// Pick the deposition site on a surface for a given rank.
///
/// This function calculates a deposition site based on the rank and the
/// surface size.
///
/// Parameters
/// ----------
/// rank : u32
///     The number of time steps elapsed.
/// surface_size : u32
///     The size of the surface on which deposition is to take place.
///     Must be even power of two.
///
/// Returns
/// -------
/// u32
///     Deposition site within surface.
pub fn pick_deposition_site(rank: u32, surface_size: u32) u32 {
    // assume power of 2 surface size
    std.debug.assert(@popCount(surface_size) == 1);
    std.debug.assert(surface_size > 1);

    const hanoi_value = hanoi.get_hanoi_value_at_index(rank);
    const hanoi_incidence = hanoi.get_hanoi_value_incidence_at_index(rank);

    const bin_index = hanoi_incidence; // zero indexed
    const num_available_bins = surface_size / 2;
    if (bin_index >= num_available_bins) {
        const longest_bin_width = get_nth_bin_width(0, surface_size);
        const largest_active_hanoi = hanoi.get_max_hanoi_value_through_index(rank);
        std.debug.assert(largest_active_hanoi > hanoi_value);
        std.debug.assert(largest_active_hanoi >= longest_bin_width);
        var smallest_active_hanoi = largest_active_hanoi - longest_bin_width + 1;
        smallest_active_hanoi += @intFromBool( // correction factor, if needed
            hanoi.get_incidence_count_of_hanoi_value_through_index(
                smallest_active_hanoi, rank // zig-fmt: off
            ) // zig-fmt: off
            >= num_available_bins
        );
        std.debug.assert( // check is active
            hanoi.get_incidence_count_of_hanoi_value_through_index(
                smallest_active_hanoi, rank // zig-fmt: off
            ) // zig-fmt: off
            < num_available_bins
        );
        std.debug.assert( // check is smallest active --- smaller are inactive
            hanoi.get_incidence_count_of_hanoi_value_through_index(
                smallest_active_hanoi - 1, rank // zig-fmt: off
            ) // zig-fmt: off
            >= num_available_bins
        );  // zig-fmt: off
        const smallest_active_hanoi_rank = hanoi.get_index_of_hanoi_value_next_incidence(
            smallest_active_hanoi, // zig-fmt: off
            rank, // zig-fmt: off
            1,
        );

        const active_cadence = ( // zig-fmt: off
            hanoi.get_hanoi_value_index_offset(smallest_active_hanoi) + 1
        );
        std.debug.assert(@popCount(active_cadence) == 1);

        var next_active_rank = smallest_active_hanoi_rank;
        if (next_active_rank - rank > active_cadence) {
            next_active_rank -= active_cadence;
        }

        std.debug.assert(rank < next_active_rank);
        std.debug.assert(rank < rank + active_cadence);
        std.debug.assert( // zig-fmt: off
            hanoi.get_hanoi_value_at_index(next_active_rank) // zig-fmt: off
            >= smallest_active_hanoi // zig-fmt: off
        );
        return pick_deposition_site( // zig-fmt: off
            next_active_rank, // zig-fmt: off
            surface_size, // zig-fmt: off
        );
    } else {
        const bin_width = get_nth_bin_width(bin_index, surface_size);
        const within_bin_position = hanoi_value % bin_width;

        const bin_position = get_nth_bin_position(bin_index, surface_size);

        // index 0 reserved
        const res = 1 + bin_position + within_bin_position;
        std.debug.assert(1 <= res and res < surface_size);
        return res;
    }
}
