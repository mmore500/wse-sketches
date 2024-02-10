pub fn get_num_positions(surfaceSize: i32) i32 {
    // site 0 on actual surface is excluded
    return surfaceSize - 1;
}
