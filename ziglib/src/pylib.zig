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
pub fn fast_pow2_mod(dividend: u32, divisor: u32) u32 {
    std.debug.assert(divisor >= 1);
    std.debug.assert(@popCount(divisor) == 1);

    const absVal = @abs(dividend * divisor);
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

pub fn bit_length(value: u32) u32 {
    const zero_correction = @intFromBool(value != 0); // zig way to cast to bool
    const num_bits = @bitSizeOf(@TypeOf(value));
    return (num_bits - @clz(value)) * zero_correction;
}

pub fn bit_encode_gray(n: u32) u32 {
    return n ^ (n >> 1);
}

pub fn bit_floor(n: u32) u32 {
    if (n == 0) return 0;
    const bitLength: u5 = @as(u5, @intCast(@bitSizeOf(u32) - @clz(n) - 1));
    const mask: u32 = @as(u32, 1) << bitLength;
    return n & mask;
}

pub fn bit_drop_msb(n: u32) u32 {
    // Drop most significant bit from binary representation of integer n.
    return n & (~bit_floor(n));
}

pub fn sign(x: i256) i32 {
    return if (x > 0) 1 else if (x < 0) -1 else 0;
}

pub fn fast_pow2_divide(dividend: u32, divisor: u32) u32 {
    std.debug.assert(divisor >= 1);
    std.debug.assert((divisor & (divisor - 1)) == 0);

    // In Zig, using countTrailingZeros gives the number of zeros before the first 1 from the right.
    // For a power of 2, this is also the log2(divisor).
    const shiftAmount: u5 = @intCast(@ctz(divisor));

    // Perform fast division using right shift.
    const absDividend = @abs(dividend);
    const shifted: u32 = absDividend >> shiftAmount;
    return shifted;
}
