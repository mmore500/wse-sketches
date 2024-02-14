const tilted = @import("tilted.zig");

pub fn pick_deposition_site(rank: u32, surfaceSize: u32) u32 {
    const ansatz = tilted.pick_deposition_site(rank, surfaceSize);
    if (ansatz != 0) {
        return ansatz;
    } else {
        return tilted.pick_deposition_site(rank + 1, surfaceSize);
    }
}
