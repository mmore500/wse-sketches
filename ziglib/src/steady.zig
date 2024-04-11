const std = @import("std");
const assert = std.debug.assert;
const pylib = @import("pylib.zig");

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
    assert(n >= 0);
    assert(n < get_num_segments(surface_size));
    var m = n;

    if (n == 0) {
        return 0;
    }

    const bit_count = 32 - @clz(surface_size) - pylib.bit_count_immediate_zeros(surface_size);
    assert(bit_count == 1);
    const mbw_initial = @ctz(surface_size);
    assert(mbw_initial == get_nth_bin_width(0, surface_size));

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
    assert(n >= 0);
    assert(n < get_num_segments(surface_size));

    const bit_length = pylib.bit_length(surface_size);

    assert(bit_length - 1 == get_nth_bin_width(0, surface_size));

    return bit_length - n - 1;
}

pub fn get_nth_bin_position(n: u32, surface_size: u32) u32 {
    assert(n >= 0);
    assert(n < get_num_bins(surface_size));
    const bit_count = 32 - @clz(surface_size) - pylib.bit_count_immediate_zeros(surface_size);
    assert(bit_count == 1);

    if (n == 0) {
        return 0;
    }

    var m = n;

    m -= 1;

    const completed_bins = pylib.bit_floor(m + 1) - 1;

    assert(32 - @clz(completed_bins) - pylib.bit_count_immediate_zeros(completed_bins) == pylib.bit_length(completed_bins));

    assert(completed_bins >= m / 2 and completed_bins <= m);
    const completed_segments = 1 + (32 - @clz(completed_bins) - pylib.bit_count_immediate_zeros(completed_bins)); // Include 0th segment.

    var position = get_nth_segment_position(completed_segments, surface_size);

    const num_unhandled_bins = m - completed_bins;
    if (num_unhandled_bins > 0) {
        const unhandled_segment_bin_width = get_nth_segment_bin_width(completed_segments, surface_size);
        position += num_unhandled_bins * unhandled_segment_bin_width;
    }

    return position;
}
