const std = @import("std");

pub fn get_a000295_value_at_index(n: i64) i64 {
    const adjustedN = n + 1;
    const shift: u6 = @intCast(adjustedN);
    return (@as(i64, 1) << shift) - adjustedN - 1;
}

pub fn get_a000295_index_of_value(v: i32) i32 {
    // Compute ansatz: the initial estimate based on the bit length of (v + 1)
    var ansatz = 32 - @clz(v + 1) - 1;

    // Calculate the value at the ansatz index and correct if necessary
    var correction = get_a000295_value_at_index(ansatz) > v;
    return ansatz - @intFromBool(correction);
}

pub fn get_a048881_value_at_index(n: i32) i32 {
    // Use std.math.popCount to count the number of bits set to 1.
    // std.math.popCount returns the population count of a value, which is the equivalent of Python's .bit_count().
    return @popCount(n + 1) - 1;
}
