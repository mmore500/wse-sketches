const std = @import("std");
const pylib = @import("pylib.zig");

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

    const product = dividend * divisor;
    return (dividend + product) & (divisor - 1);
}

/// Reverse the bit sequence of an integer.
pub fn bit_reverse(n: u32) u32 {
    var res: u32 = 0;
    var temp: u32 = n;
    while (temp > 0) {
        res = (res << 1) | (temp & 1);
        temp >>= 1;
    }
    return res;
}

/// Calculate the smallest power of 2 not smaller than n.
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

/// Return the number of bits necessary to represent an integer in binary,
/// excluding the sign and leading zeros.
pub fn bit_length(value: u32) u32 {
    const zero_correction = @intFromBool(value != 0); // zig way to cast to bool
    const num_bits = @bitSizeOf(@TypeOf(value));
    return (num_bits - @clz(value)) * zero_correction;
}

/// Encode an integer using Gray code.
///
/// Gray code is a binary numeral system where two successive values differ in
/// only one bit. See <https://en.wikipedia.org/wiki/Gray_code>.
pub fn bit_encode_gray(n: u32) u32 {
    return n ^ (n >> 1);
}

/// Calculate the largest power of two not greater than n.
///
/// If zero, returns zero.
pub fn bit_floor(n: u32) u32 {
    const shift: u5 = @intCast(bit_length(n >> 1));
    const mask: u32 = @as(u32, 1) << shift;
    return n & mask;
}

/// Drop most significant bit from binary representation of integer n.
pub fn bit_drop_msb(n: u32) u32 {
    return n & (~bit_floor(n));
}

/// Calculate the sign of an integer.
///
/// This function takes an integer input and returns:
/// - 1 if the number is positive,
/// - 0 if the number is zero, or
/// - -1 if the number is negative.
///
/// Returns
/// -------
/// i32
///     The sign of the input integer (1, 0, or -1).
pub fn sign(x: i256) i32 {
    return if (x > 0) 1 else if (x < 0) -1 else 0;
}

/// Perform fast division using bitwise operations.
///
/// Parameters
/// ----------
/// dividend : u32
///     The dividend of the division operation.
/// divisor : u32
///     The divisor of the division operation. Must be a positive integer and a
///     power of 2.
///
/// Returns
/// -------
/// u32
///     The quotient of dividing the dividend by the divisor.
pub fn fast_pow2_divide(dividend: u32, divisor: u32) u32 {
    std.debug.assert(divisor >= 1);
    std.debug.assert(@popCount(divisor) == 1); // perfect power of 2

    const shiftAmount: u5 = @intCast(@ctz(divisor));

    // Perform fast division using right shift.
    const shifted: u32 = dividend >> shiftAmount;
    return shifted;
}

pub fn bit_count_immediate_zeros(x: u32) u32 {
    if (x == 0) return 0;
    const bitLen = @bitSizeOf(u32) - @clz(x);
    const droppedMsb = bit_drop_msb(x);
    const droppedMsbLen = if (droppedMsb == 0) 0 else @bitSizeOf(u32) - @clz(droppedMsb);
    return bitLen - droppedMsbLen - 1;
}

pub fn bit_invert(n: u32) u32 {
    const lhs: u32 = 1;
    const rhs: u5 = @intCast(pylib.bit_length(n));
    const mask = (lhs << rhs) - 1;
    return n ^ mask;
}
