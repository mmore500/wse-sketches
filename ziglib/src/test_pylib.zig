const std = @import("std");
const pylib = @import("pylib.zig");

test "fast_pow2_mod tests" {
    // positive dividend and power of 2
    try std.testing.expectEqual(pylib.fast_pow2_mod(16, 1), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(17, 1), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(18, 1), 0);

    // negative dividend and power of 2
    try std.testing.expectEqual(pylib.fast_pow2_mod(-15, 2), 1);
    try std.testing.expectEqual(pylib.fast_pow2_mod(-2, 2), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(-1, 4), 3);

    // zero dividend
    try std.testing.expectEqual(pylib.fast_pow2_mod(0, 4), 0);
}

test "bit_reverse tests" {
    try std.testing.expect(pylib.bit_reverse(0) == 0);
    try std.testing.expect(pylib.bit_reverse(1) == 1);
    try std.testing.expect(pylib.bit_reverse(2) == 1);
    try std.testing.expect(pylib.bit_reverse(3) == 3);
    try std.testing.expect(pylib.bit_reverse(4) == 1);
    try std.testing.expect(pylib.bit_reverse(5) == 5);
    try std.testing.expect(pylib.bit_reverse(6) == 3);
    try std.testing.expect(pylib.bit_reverse(7) == 7);
    try std.testing.expect(pylib.bit_reverse(8) == 1);
    try std.testing.expect(pylib.bit_reverse(9) == 9);
    try std.testing.expect(pylib.bit_reverse(10) == 5);
    try std.testing.expect(pylib.bit_reverse(255) == 255);
    try std.testing.expect(pylib.bit_reverse(256) == 1);
    try std.testing.expect(pylib.bit_reverse(257) == 257);
    try std.testing.expect(pylib.bit_reverse(1234567890) == 631256265);
}
