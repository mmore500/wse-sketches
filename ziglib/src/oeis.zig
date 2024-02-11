pub fn get_a000295_value_at_index(n: i256) i256 {
    const adjustedN = n + 1;
    const shift: u8 = @intCast(adjustedN);
    return (@as(i256, 1) << shift) - adjustedN - 1;
}
