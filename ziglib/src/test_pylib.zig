const std = @import("std");
const pylib = @import("pylib.zig");

test "positive dividend and power of 2" {
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
