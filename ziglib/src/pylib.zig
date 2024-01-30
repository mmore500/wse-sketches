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
