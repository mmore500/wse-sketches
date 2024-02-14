const std = @import("std");

pub fn get_a000295_value_at_index(n: u32) u32 {
    const adjustedN = n + 1;
    const shift: u5 = @intCast(adjustedN);
    return (@as(u32, 1) << shift) - adjustedN - 1;
}

pub fn get_a000295_index_of_value(v: u32) u32 {
    // Compute ansatz: the initial estimate based on the bit length of (v + 1)
    const ansatz = 32 - @clz(v + 1) - 1;

    // Calculate the value at the ansatz index and correct if necessary
    const correction = get_a000295_value_at_index(ansatz) > v;
    return ansatz - @intFromBool(correction);
}

pub fn get_a048881_value_at_index(n: u32) u32 {
    // Use std.math.popCount to count the number of bits set to 1.
    return @popCount(n + 1) - 1;
}
