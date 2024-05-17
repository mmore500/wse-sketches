const std = @import("std");

const pylib = @import("pylib.zig");

/// Return the value of A000295 at the given index.
///
/// See <https://oeis.org/A000295>. Note: uses -1 as the first index, i.e.,
/// skips zeroth element.
pub fn get_a000295_value_at_index(n: u32) u32 {
    const adjustedN = n + 1;
    const shift: u5 = @intCast(adjustedN);
    return (@as(u32, 1) << shift) - adjustedN - 1;
}

/// Return the greatest index of A000295 with value `<= v`.
///
/// See <https://oeis.org/A000295>. Note: uses -1 as the first index, i.e.,
/// skips zeroth element.
pub fn get_a000295_index_of_value(v: u32) u32 {
    // Compute ansatz: the initial estimate based on the bit length of (v + 1)
    const ansatz = pylib.bit_length(v + 1) - 1;

    // Calculate the value at the ansatz index and correct if necessary
    const correction = get_a000295_value_at_index(ansatz) > v;
    return ansatz - @intFromBool(correction);
}

/// See <https://oeis.org/A048881>.
///
/// Credit Chai Wah Wu, Nov 15 2022
pub fn get_a048881_value_at_index(n: u32) u32 {
    return @popCount(n + 1) - 1;
}

pub fn get_a083058_value_at_index(n: u32) u32 {
    const add: u32 = @intFromBool(n == 1);
    return n - pylib.bit_length(n) + add;
}

pub fn get_a083058_index_of_value(value: u32) u32 {
    std.debug.assert(value >= 1);

    const valueBitLength = pylib.bit_length(value);
    const correction: bool = ( // zig fmt: off
        (pylib.bit_ceil(value) - value) <= valueBitLength  // zig fmt: off
        and (pylib.bit_ceil(value) - value) > 0  // zig fmt: off
    );
    const first: u32 = @intFromBool(value <= 2);
    const second: u32 = @intFromBool(correction);
    return value + valueBitLength + first + second;
}
