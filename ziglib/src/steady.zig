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
