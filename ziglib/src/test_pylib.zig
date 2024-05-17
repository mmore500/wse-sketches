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
    try std.testing.expectEqual(@as(u32, 0b00000000), pylib.bit_floor(0b00000000));
    try std.testing.expectEqual(@as(u32, 0b00000001), pylib.bit_floor(0b00000001));
    try std.testing.expectEqual(@as(u32, 0b00000010), pylib.bit_floor(0b00000010));
    try std.testing.expectEqual(@as(u32, 0b00000010), pylib.bit_floor(0b00000011));
    try std.testing.expectEqual(@as(u32, 0b00000100), pylib.bit_floor(0b00000100));
    try std.testing.expectEqual(@as(u32, 0b00000100), pylib.bit_floor(0b00000101));
    try std.testing.expectEqual(@as(u32, 0b00000100), pylib.bit_floor(0b00000110));
    try std.testing.expectEqual(@as(u32, 0b00000100), pylib.bit_floor(0b00000111));
    try std.testing.expectEqual(@as(u32, 0b00001000), pylib.bit_floor(0b00001000));
    try std.testing.expectEqual(@as(u32, 0b00001000), pylib.bit_floor(0b00001001));
}

test "bit_length tests" {
    const expectEqual = std.testing.expectEqual;

    try expectEqual(@as(u32, 0), pylib.bit_length(0b0));
    try expectEqual(@as(u32, 1), pylib.bit_length(0b1));
    try expectEqual(@as(u32, 2), pylib.bit_length(0b10));
    try expectEqual(@as(u32, 2), pylib.bit_length(0b11));

    try expectEqual(@as(u32, 3), pylib.bit_length(0b101));
    try expectEqual(@as(u32, 3), pylib.bit_length(0b111));
    try expectEqual(@as(u32, 4), pylib.bit_length(0b1100));
    try expectEqual(@as(u32, 5), pylib.bit_length(0b10000));

    try expectEqual(@as(u32, 31), pylib.bit_length(0x7FFFFFFF));
    try expectEqual(@as(u32, 31), pylib.bit_length(0x7FA0873F));

    try expectEqual(@as(u32, 32), pylib.bit_length(0xFFFFFFFF));
    try expectEqual(@as(u32, 32), pylib.bit_length(0x80000000));
    try expectEqual(@as(u32, 32), pylib.bit_length(0x800A0000));
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
    try std.testing.expectEqual(pylib.sign(1 << 128), 1);

    // Test sign zero
    try std.testing.expectEqual(pylib.sign(0), 0);

    // Test sign negative
    try std.testing.expectEqual(pylib.sign(-1), -1);
    try std.testing.expectEqual(pylib.sign(-3), -1);
    try std.testing.expectEqual(pylib.sign(-999), -1);
    try std.testing.expectEqual(pylib.sign(-(1 << 128)), -1);
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
}

const A290255 = [_]u32{ 0, 1, 0, 2, 1, 0, 0, 3, 2, 1, 1, 0, 0, 0, 0, 4, 3, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 5, 4, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 5, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 };

fn bit_count_immediate_zeros_reference(num: u32) u32 {
    var count: u32 = 0;
    var foundOne: bool = false;
    var mask: u32 = 1 << 31;

    while (mask != 0) {
        if ((num & mask) != 0) {
            if (foundOne) {
                break;
            }
            foundOne = true;
        } else if (foundOne) {
            count += 1;
        }
        mask = mask >> 1;
    }
    if (foundOne) {
        return count;
    } else {
        return 0;
    }
}

test "bit_count_immediate_zeros_reference sequence tests" {
    inline for (A290255, 0..) |expected, index| {
        const n = index + 1;
        const calculated = bit_count_immediate_zeros_reference(n);
        try std.testing.expectEqual(expected, calculated);
    }
}

test "bit_count_immediate_zeros_reference_implementation" {
    const testIndices = [_]u32{ 0, 1, 2, 3, 4, 1023, 1024, 2047, 2048, 0xFFFF_FFFE, 0xFFFF_FFFF };

    for (testIndices) |n| {
        const result1 = pylib.bit_count_immediate_zeros(n);
        const result2 = bit_count_immediate_zeros_reference(n);
        try std.testing.expectEqual(result1, result2);
    }
}

test "test_bit_invert_known_values" {
    const TestCase = struct {
        n: u32,
        expected: u32,
    };

    const cases = [_]TestCase{
        TestCase{ .n = 0b0, .expected = 0b0 },
        TestCase{ .n = 0b1, .expected = 0b0 },
        TestCase{ .n = 0b10, .expected = 0b1 },
        TestCase{ .n = 0b11, .expected = 0b0 },
        TestCase{ .n = 0b100, .expected = 0b11 },
        TestCase{ .n = 0b101, .expected = 0b10 },
        TestCase{ .n = 0b110, .expected = 0b1 },
        TestCase{ .n = 0b111, .expected = 0b0 },
        TestCase{ .n = 0b1000, .expected = 0b111 },
        TestCase{ .n = 0b1001, .expected = 0b110 },
        TestCase{ .n = 0b1010, .expected = 0b101 },
        TestCase{ .n = 0b1011, .expected = 0b100 },
        TestCase{ .n = 0b1100, .expected = 0b11 },
        TestCase{ .n = 0b1101, .expected = 0b10 },
        TestCase{ .n = 0b1110, .expected = 0b1 },
        TestCase{ .n = 0b1111, .expected = 0b0 },
        TestCase{ .n = 0b10000, .expected = 0b1111 },
        TestCase{ .n = 0b100000, .expected = 0b11111 },
        TestCase{ .n = 0b1000000, .expected = 0b111111 },
        TestCase{ .n = 0b10000000, .expected = 0b1111111 },
        TestCase{ .n = 0b100000000, .expected = 0b11111111 },
    };

    for (cases) |test_case| {
        const result = pylib.bit_invert(test_case.n);
        try std.testing.expect(result == test_case.expected);
    }
}

test "test_bit_count_leading_ones" {
    const TestCase = struct {
        n: u32,
        expected: u32,
    };

    const testCases = [_]TestCase{
        TestCase{ .n = 0b0, .expected = 0 },
        TestCase{ .n = 0b1, .expected = 1 },
        TestCase{ .n = 0b11, .expected = 2 },
        TestCase{ .n = 0b111, .expected = 3 },
        TestCase{ .n = 0b101, .expected = 1 },
        TestCase{ .n = 0b1001, .expected = 1 },
        TestCase{ .n = 0b1011, .expected = 1 },
        TestCase{ .n = 0b1101, .expected = 2 },
        TestCase{ .n = 0b11110000, .expected = 4 },
        TestCase{ .n = 0b10000000, .expected = 1 },
    };

    for (testCases) |testCase| {
        const result = pylib.bit_count_leading_ones(testCase.n);
        try std.testing.expectEqual(testCase.expected, result);
    }
}
