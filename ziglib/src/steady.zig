const std = @import("std");
const assert = std.debug.assert;

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
