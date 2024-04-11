const std = @import("std");
const assert = std.debug.assert;
const pylib = @import("pylib.zig");

/// How many surface sites are made available to the surface update algorithm?
pub fn get_num_positions(surfaceSize: i32) i32 {
    // site 0 on actual surface is excluded
    return surfaceSize - 1;
}

pub fn get_num_bins(surface_size: u32) u32 {
    // In Zig, `std.math.countOneBits(u32)` is used to count the number of bits set to 1.
    // assert(std.math.countOneBits(u32, surface_size) == 1);
    // Right shift by 1 to divide by 2.
    return surface_size >> 1;
}

pub fn get_num_segments(surface_size: u32) u32 {
    const num_bins = get_num_bins(surface_size);
    // Calculate the bit length required to represent `num_bins`.
    if (num_bins == 0) return 0; // Special case for 0, as its bit length is 0.
    // Use the fact that bit length is the position of the highest set bit + 1.
    return 32 - @clz(num_bins);
}

pub fn get_nth_bin_width(n: u32, surface_size: u32) u32 {
    // In Zig, `std.math.ctz(u32, value)` is used to count the number of trailing zeros.
    // This is a direct substitute for `bit_count_immediate_zeros` in the Python code.
    // The `+ 1` at the end accounts for the formula adjustment as per the Python function.
    return pylib.bit_count_immediate_zeros(n + (surface_size >> 1)) + 1;
}

pub fn get_nth_segment_position(n: u32, surface_size: u32) u32 {
    // Check that n is within the valid range.
    assert(n < get_num_segments(surface_size) and n >= 0);
    var m = n;

    if (n == 0) {
        return 0;
    }

    // Ensure surface_size is a power of 2.
    const bit_count = 32 - @clz(surface_size) - pylib.bit_count_immediate_zeros(surface_size);
    assert(bit_count == 1);
    const mbw_initial = @ctz(surface_size);
    assert(mbw_initial == get_nth_bin_width(0, surface_size));

    var position: u32 = mbw_initial; // Special case the first one-bin segment.
    var mbw: u32 = mbw_initial - 1; // New largest bin width is one less than the first.
    m -= 1; // We've handled one bin.

    // Calculate position based on the sum of bin widths before the nth bin.
    const lhs: u32 = 1;
    const mu5: u5 = @intCast(m);

    position += (lhs << mu5) * mbw - mbw;

    // Adjust position based on a mathematical formula.
    position -= m * (lhs << mu5) + 2 - (lhs << (mu5 + 1));

    return position;
}
