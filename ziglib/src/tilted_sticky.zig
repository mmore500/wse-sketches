const tilted = @import("tilted.zig");

/// Pick the deposition site on a surface for a given rank.
///
/// This function calculates a deposition site based on the rank and the
/// surface size.
/// Parameters
/// ----------
/// rank : u32
///     The number of time steps elapsed.
/// surface_size : u32
///     The size of the surface on which deposition is to take place.
///     Must be even power of two.
/// Returns
/// -------
/// u32
///     Deposition site within surface.
pub fn pick_deposition_site(rank: u32, surfaceSize: u32) u32 {
    const ansatz = tilted.pick_deposition_site(rank, surfaceSize);
    if (ansatz != 0) {
        return ansatz;
    } else {
        return tilted.pick_deposition_site(rank + 1, surfaceSize);
    }
}
