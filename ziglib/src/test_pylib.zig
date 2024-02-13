const std = @import("std");
const pylib = @import("pylib.zig");

test "fast_pow2_mod tests" {
    // positive dividend and power of 2
    try std.testing.expectEqual(pylib.fast_pow2_mod(16, 1), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(17, 1), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(18, 1), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(15, 2), 1);
    try std.testing.expectEqual(pylib.fast_pow2_mod(2, 2), 0);
    try std.testing.expectEqual(pylib.fast_pow2_mod(3, 4), 3);

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

test "bit_ceil test cases" {
    try std.testing.expect(pylib.bit_ceil(0) == 1);
    try std.testing.expect(pylib.bit_ceil(1) == 1);
    try std.testing.expect(pylib.bit_ceil(2) == 2);
    try std.testing.expect(pylib.bit_ceil(3) == 4);
    try std.testing.expect(pylib.bit_ceil(4) == 4);
    try std.testing.expect(pylib.bit_ceil(5) == 8);
    try std.testing.expect(pylib.bit_ceil(1000) == 1024);
    try std.testing.expect(pylib.bit_ceil(64) == 64);
    try std.testing.expect(pylib.bit_ceil(65534) == 65536);
    try std.testing.expect(pylib.bit_ceil(65536) == 65536);
    try std.testing.expect(pylib.bit_ceil(255) == 256);
}

test "bit_encode_gray tests" {
    try std.testing.expect(pylib.bit_encode_gray(0) == 0);
    try std.testing.expect(pylib.bit_encode_gray(1) == 1);
    try std.testing.expect(pylib.bit_encode_gray(2) == 3);
    try std.testing.expect(pylib.bit_encode_gray(3) == 2);
    try std.testing.expect(pylib.bit_encode_gray(4) == 6);
    try std.testing.expect(pylib.bit_encode_gray(5) == 7);
    try std.testing.expect(pylib.bit_encode_gray(6) == 5);
    try std.testing.expect(pylib.bit_encode_gray(7) == 4);
    try std.testing.expect(pylib.bit_encode_gray(8) == 12);
    try std.testing.expect(pylib.bit_encode_gray(9) == 13);
    try std.testing.expect(pylib.bit_encode_gray(10) == 15);
    try std.testing.expect(pylib.bit_encode_gray(255) == 128);
    try std.testing.expect(pylib.bit_encode_gray(256) == 384);
    try std.testing.expect(pylib.bit_encode_gray(257) == 385);
    try std.testing.expect(pylib.bit_encode_gray(1234567890) == 1834812347);
}

test "test_bit_floor" {
    try std.testing.expectEqual(@as(i32, 0b00000000), pylib.bit_floor(0b00000000));
    try std.testing.expectEqual(@as(i32, 0b00000001), pylib.bit_floor(0b00000001));
    try std.testing.expectEqual(@as(i32, 0b00000010), pylib.bit_floor(0b00000010));
    try std.testing.expectEqual(@as(i32, 0b00000010), pylib.bit_floor(0b00000011));
    try std.testing.expectEqual(@as(i32, 0b00000100), pylib.bit_floor(0b00000100));
    try std.testing.expectEqual(@as(i32, 0b00000100), pylib.bit_floor(0b00000101));
    try std.testing.expectEqual(@as(i32, 0b00000100), pylib.bit_floor(0b00000110));
    try std.testing.expectEqual(@as(i32, 0b00000100), pylib.bit_floor(0b00000111));
    try std.testing.expectEqual(@as(i32, 0b00001000), pylib.bit_floor(0b00001000));
    try std.testing.expectEqual(@as(i32, 0b00001000), pylib.bit_floor(0b00001001));
}

test "bit_drop_msb tests" {
    const test_cases = .{
        .{ 0, 0 },
        .{ 1, 0 },
        .{ 2, 0 },
        .{ 3, 1 },
        .{ 4, 0 },
        .{ 5, 1 },
        .{ 6, 2 },
        .{ 7, 3 },
        .{ 8, 0 },
        .{ 9, 1 },
        .{ 10, 2 },
        .{ 255, 127 },
        .{ 256, 0 },
        .{ 257, 1 },
        .{ 1234567890, 160826066 },
    };

    inline for (test_cases) |test_case| {
        const input = test_case[0];
        const expected = test_case[1];
        const output = pylib.bit_drop_msb(input);
        try std.testing.expectEqual(output, expected);
    }
}

test "sign function tests" {
    // Test sign positive
    try std.testing.expectEqual(pylib.sign(1), 1);
    try std.testing.expectEqual(pylib.sign(5), 1);
    try std.testing.expectEqual(pylib.sign(1000), 1);
    try std.testing.expectEqual(pylib.sign(1 << 128), 1); // Zig does not support 2**128 directly for integer types, adjust as needed

    // Test sign zero
    try std.testing.expectEqual(pylib.sign(0), 0);

    // Test sign negative
    try std.testing.expectEqual(pylib.sign(-1), -1);
    try std.testing.expectEqual(pylib.sign(-3), -1);
    try std.testing.expectEqual(pylib.sign(-999), -1);
    try std.testing.expectEqual(pylib.sign(-(1 << 128)), -1); // Adjust as needed
}

test "fast_pow2_divide comprehensive tests" {
    // Positive dividend and divisor
    inline for ([_]struct { dividend: i32, divisor: i32, expected: i32 }{
        .{ .dividend = 16, .divisor = 4, .expected = 4 },
        .{ .dividend = 17, .divisor = 4, .expected = 4 },
        .{ .dividend = 18, .divisor = 4, .expected = 4 },
        .{ .dividend = 19, .divisor = 4, .expected = 4 },
        .{ .dividend = 20, .divisor = 4, .expected = 5 },
        .{ .dividend = 32, .divisor = 8, .expected = 4 },
        .{ .dividend = 64, .divisor = 2, .expected = 32 },
        .{ .dividend = 16, .divisor = 1, .expected = 16 },
        .{ .dividend = 0, .divisor = 1, .expected = 0 },
    }) |test_case| {
        try std.testing.expectEqual(pylib.fast_pow2_divide(test_case.dividend, test_case.divisor), test_case.expected);
    }

    // Negative dividend and positive divisor
    inline for ([_]struct { dividend: i32, divisor: i32, expected: i32 }{
        .{ .dividend = -15, .divisor = 4, .expected = -3 },
        .{ .dividend = -1, .divisor = 4, .expected = 0 },
        .{ .dividend = -1, .divisor = 8, .expected = 0 },
        .{ .dividend = -16, .divisor = 8, .expected = -2 },
        .{ .dividend = -16, .divisor = 4, .expected = -4 },
        .{ .dividend = -17, .divisor = 4, .expected = -4 },
        .{ .dividend = -18, .divisor = 4, .expected = -4 },
        .{ .dividend = -19, .divisor = 4, .expected = -4 },
        .{ .dividend = -20, .divisor = 4, .expected = -5 },
        .{ .dividend = -32, .divisor = 8, .expected = -4 },
        .{ .dividend = -64, .divisor = 2, .expected = -32 },
        .{ .dividend = -16, .divisor = 1, .expected = -16 },
        .{ .dividend = -0, .divisor = 1, .expected = -0 },

        // Add other cases as necessary
    }) |test_case| {
        try std.testing.expectEqual(pylib.fast_pow2_divide(test_case.dividend, test_case.divisor), test_case.expected);
    }

    // Additional tests for edge cases and error conditions could be added here.
    // Remember, Zig encourages handling errors with error values rather than panics
    // for conditions that can be reasonably checked and handled.
}
