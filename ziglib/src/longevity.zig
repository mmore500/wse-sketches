const pylib = @import("pylib.zig");

pub fn get_longevity_level_of_index(index: u32) u32 {
    return pylib.bit_length(index);
}

pub fn get_longevity_offset_of_level(level: u32, num_indices: u32) u32 {
    const correction: u32 = @intFromBool(level != 0);
    return (num_indices >> @intCast(level)) * correction;
}

pub fn get_longevity_mapped_position_of_index(index: u32, num_indices: u32) u32 {
    const longevity_level = get_longevity_level_of_index(index);
    const position_within_level = index - pylib.bit_floor(index);

    const offset = get_longevity_offset_of_level(longevity_level, num_indices);
    const spacing = offset << 1;

    return offset + spacing * position_within_level;
}
