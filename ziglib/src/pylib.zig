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

pub fn bit_ceil(n: u32) u32 {
    std.debug.assert(n >= 0);

    if (n == 0) return 1;
    var m = n - 1;
    var exp: u5 = 0;
    while (m != 0) {
        exp += 1;
        m >>= 1;
    }
    return @as(u32, 1) << exp;
}

pub fn bit_encode_gray(n: u32) u32 {
    return n ^ (n >> 1);
}

pub fn bit_floor(n: i32) i32 {
    if (n == 0) return 0;
    const bitLength: u5 = @as(u5, @intCast(@bitSizeOf(i32) - @clz(n) - 1));
    var mask: i32 = @as(i32, 1) << bitLength;
    return n & mask;
}

pub fn bit_drop_msb(n: i32) i32 {
    // Drop most significant bit from binary representation of integer n.
    return n & (~bit_floor(n));
}
