const std = @import("std");

/// Perform fast mod using bitwise operations.
///
/// Parameters
/// ----------
/// dividend : int
///     The dividend of the mod operation.
/// divisor : int
///     The divisor of the mod operation. Must be a positive integer and a
///     power of 2.
///
/// Returns
/// -------
/// int
///     The remainder of dividing the dividend by the divisor.
pub fn fast_pow2_mod(dividend: i32, divisor: i32) i32 {
    std.debug.assert(divisor >= 1);
    std.debug.assert(@popCount(divisor) == 1);

    const absVal = std.math.absInt(dividend * divisor) catch unreachable;
    return (dividend + absVal) & (divisor - 1);
}

pub fn bit_reverse(n: u32) u32 {
    var res: u32 = 0;
    var temp: u32 = n;
    while (temp > 0) {
        res = (res << 1) | (temp & 1);
        temp >>= 1;
    }
    return res;
}
