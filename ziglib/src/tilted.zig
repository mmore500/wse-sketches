const std = @import("std");

pub fn get_global_num_reservations_at_epoch(epoch: i32, surfaceSize: i32) i32 {
    // Zig does not have a direct bit_count method, so you would need to implement or use an equivalent.
    std.debug.assert(std.bitops.popCount(u32(surfaceSize)) == 1); // Assuming surfaceSize is positive and fits in u32
    return surfaceSize >> (1 + epoch);
}

pub fn getHanoiValueIndexOffset(value: i32) i32 {
    return (1 << value) - 1; // Equivalent to 2**value - 1 in Python
}
