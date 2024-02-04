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

pub fn get_hanoi_value_index_offset(value: i32) i32 {
    return (1 << value) - 1;
}
