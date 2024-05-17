const std = @import("std");
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
    var m = n;

    if (n == 0) {
        return 0;
    }

    const bit_count = 32 - @clz(surface_size) - pylib.bit_count_immediate_zeros(surface_size);
    std.debug.assert(bit_count == 1);
    const mbw_initial = @ctz(surface_size);
    std.debug.assert(mbw_initial == get_nth_bin_width(0, surface_size));

    var position: u32 = mbw_initial;
    var mbw: u32 = mbw_initial - 1;
    m -= 1;

    const lhs: u32 = 1;
    const mu5: u5 = @intCast(m);

    position += (lhs << mu5) * mbw - mbw;

    position -= m * (lhs << mu5) + 2 - (lhs << (mu5 + 1));

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
    const bit_count = 32 - @clz(surface_size) - pylib.bit_count_immediate_zeros(surface_size);
    std.debug.assert(bit_count == 1);

    if (n == 0) {
        return 0;
    }

    var m = n;

    m -= 1;

    const completed_bins = pylib.bit_floor(m + 1) - 1;

    std.debug.assert(
        32 - @clz(completed_bins) - pylib.bit_count_immediate_zeros(completed_bins)
        == pylib.bit_length(completed_bins)
    );

    std.debug.assert(completed_bins >= m / 2 and completed_bins <= m);
    // Include 0th segment.
    const completed_segments = 1 + (
        32
        - @clz(completed_bins)
        - pylib.bit_count_immediate_zeros(completed_bins)
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
    const A083058Index = oeis.get_a083058_index_of_value(leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(A083058Index) == leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(A083058Index - 1) < leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(A083058Index + 1) >= leadingOnes);
    std.debug.assert(oeis.get_a083058_value_at_index(A083058Index + 2) > leadingOnes);

    const ansatzSegmentFromEnd = A083058Index - 2;
    std.debug.assert(ansatzSegmentFromEnd < get_num_segments(surfaceSize));

    const ansatzSegment = get_num_segments(surfaceSize) - 1 - ansatzSegmentFromEnd;
    std.debug.assert(ansatzSegment < get_num_segments(surfaceSize) - 1);

    var correction: u32 = @intCast(position < get_nth_segment_position(ansatzSegment, surfaceSize));

    const eligibleExtraCorrection = leadingOnes == oeis.get_a083058_value_at_index(A083058Index + 1);
    if (eligibleExtraCorrection) {
        correction += @intCast(position < get_nth_segment_position(ansatzSegment - 1, surfaceSize));
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

    if (bin_segment_number == 0) {
        return 0;
    }

    const one: u32 = 1;
    const shift: u5 = @intCast(first_bin_width - bin_width - 1);
    const bin_segment_first_bin_number = one << shift;
    std.debug.assert(
        get_nth_bin_width(bin_segment_first_bin_number, surface_size)
        == bin_width
    );
    std.debug.assert(bin_segment_first_bin_number != 0);
    std.debug.assert(
        get_nth_bin_width(bin_segment_first_bin_number - 1, surface_size) 
        == bin_width + 1
    );

    const bin_segment_first_bin_position = get_nth_bin_position(bin_segment_first_bin_number, surface_size);
    std.debug.assert(bin_segment_first_bin_position <= position);

    const bin_number_within_segment = (position - bin_segment_first_bin_position) / bin_width;

    return bin_segment_first_bin_number + bin_number_within_segment;
}
