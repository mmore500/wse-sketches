const std = @import("std");
const pylib = @import("pylib.zig");

/// Returns the value at a given index in the zero-indexed, zero-based Hanoi
/// sequence.
///
/// This sequence is equivalent to the Hanoi sequence
/// ([A001511](https://oeis.org/A00151)) with all values decreased by one, and
/// is listed as [A007814](https://oeis.org/A007814) in the Online Encyclopedia
/// of Integer Sequences. The function computes the value in constant time
/// using a zero-based indexing convention.
pub fn get_hanoi_value_at_index(n: u32) u32 {
    return @ctz(n + 1);
}

/// How many times has the hanoi value at index `n` already been encountered?
///
/// Assumes zero-indexing convention. See `get_hanoi_value_at_index` for notes
/// on zero-based variant of Hanoi sequence used.
pub fn get_hanoi_value_incidence_at_index(n: u32) u32 {
    // equiv to n // 2 ** (get_hanoi_value_at_index(n) + 1)
    return n >> @intCast(get_hanoi_value_at_index(n) + 1);
}

pub fn get_hanoi_value_index_offset(value: u32) u32 {
    var shift: u5 = @intCast(value);
    return (@as(u32, 1) << shift) - 1;
}

pub fn get_hanoi_value_index_cadence(value: u32) u32 {
    var shift: u5 = @intCast(value);
    return @as(u32, 1) << (shift + 1);
}

pub fn get_max_hanoi_value_through_index(n: u32) i32 {
    // Assuming n is a 32-bit integer; adjust type if needed for your use case
    if (n <= 1) {
        return 0;
    }
    return 31 - @clz(n);
}

pub fn get_index_of_hanoi_value_nth_incidence(value: u32, n: u32) u32 {
    const offset = get_hanoi_value_index_offset(value);
    const cadence = get_hanoi_value_index_cadence(value);
    return offset + cadence * n;
}

pub fn get_incidence_count_of_hanoi_value_through_index(value: u32, n: u32) i32 {
    const m: i32 = @intCast(n);
    const offset: i32 = @intCast(get_hanoi_value_index_offset(value));
    const cadence: i32 = @intCast(get_hanoi_value_index_cadence(value));
    const dividend: i32 = @intCast(m - offset + cadence);
    const quotient = pylib.fast_pow2_divide(dividend, cadence);

    if (get_hanoi_value_at_index(n) == value) {
        return quotient - 1;
    }

    return quotient;
}

/// At what index does the next incidence of a given value occur within the
/// Hanoi sequence past the given index?
/// Assumes zero-indexing convention. See `get_hanoi_value_at_index` for notes
/// on zero-based variant of Hanoi sequence used.
pub fn get_index_of_hanoi_value_next_incidence(value: u32, index: i32, n: i32) i32 {
    const i: u32 = @intCast(index + 1);
    const m: u32 = @intCast(n);
    const incidenceCount: u32 = @intCast(get_incidence_count_of_hanoi_value_through_index(value, i));
    const res: i32 = @intCast(get_index_of_hanoi_value_nth_incidence(value, incidenceCount + m - 1));

    return res;
}
