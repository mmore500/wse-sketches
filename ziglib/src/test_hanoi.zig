const std = @import("std");

const hanoi = @import("hanoi.zig");

test "test_get_hanoi_value_at_index" {
    const A001511 = [_]u32{
        1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 5, 1, 2, 1, 3, 1, 2, 1, 4,
        1, 2, 1, 3, 1, 2, 1, 6, 1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 5,
        1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 7, 1, 2, 1, 3, 1, 2, 1, 4,
        1, 2, 1, 3, 1, 2, 1, 5, 1, 2, 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 2, 1, 6,
        1, 2, 1, 3, 1, 2, 1, 4, 1,
    };
    for (A001511, 0..) |v, i| {
        try std.testing.expectEqual(
            v - 1,
            hanoi.get_hanoi_value_at_index(@intCast(i)),
        );
    }
}

test "get_hanoi_value_incidence_at_index" {
    var hanoiValues: [100]u32 = undefined;
    for (0..100) |i| {
        hanoiValues[i] = hanoi.get_hanoi_value_at_index(@intCast(i));
    }

    for (0..100) |n| {
        var count: u32 = 0;
        for (0..n) |j| {
            if (hanoiValues[j] == hanoiValues[n]) {
                count += 1;
            }
        }
        std.debug.assert(count == hanoi.get_hanoi_value_incidence_at_index(
            @intCast(n),
        ));
    }
}

test "test_get_max_hanoi_value_through_index" {
    var hanoiValues: [1000]u32 = undefined; // Adjust type and size as necessary
    // Populate hanoiValues with Hanoi sequence values
    for (0..1000) |i| {
        var j: u32 = @intCast(i);
        hanoiValues[i] = hanoi.get_hanoi_value_at_index(j);
    }

    for (0..1000) |n| {
        var maxValue: i32 = @intCast(hanoiValues[0]);
        // Find max value up to n
        for (0..n) |j| {
            if (hanoiValues[j] > maxValue) {
                maxValue = @intCast(hanoiValues[j]);
            }
        }
        var m: u32 = @intCast(n);
        try std.testing.expectEqual(maxValue, hanoi.get_max_hanoi_value_through_index(m));
    }
}

test "test get_index_of_hanoi_value_incidence" {
    var hanoi_value: u32 = 1;
    while (hanoi_value <= 5) : (hanoi_value += 1) {
        var i: u32 = 0;
        while (i < 5) : (i += 1) {
            const index: u32 = @intCast(hanoi.get_index_of_hanoi_value_nth_incidence(hanoi_value, i));
            try std.testing.expectEqual(hanoi.get_hanoi_value_at_index(index), hanoi_value);

            var hanoi_values: std.ArrayList(u32) = std.ArrayList(u32).init(std.heap.page_allocator);
            defer hanoi_values.deinit();
            var j: u32 = 0;
            while (j < index) : (j += 1) {
                _ = try hanoi_values.append(hanoi.get_hanoi_value_at_index(j));
            }
            var count: u32 = 0;
            for (hanoi_values.items) |value| {
                if (value == hanoi_value) count += 1;
            }
            try std.testing.expectEqual(count, i);
        }
    }
}

test "test_get_incidence_count_of_hanoi_value_through_index" {
    var hanoiValues: [1000]u32 = undefined;
    // Allocator for dynamic operations
    var allocator = std.heap.page_allocator;
    _ = allocator;

    // Populate Hanoi values
    for (0..1000) |i| {
        var j: u32 = @intCast(i);
        hanoiValues[i] = hanoi.get_hanoi_value_at_index(j);
    }

    // Iterate over all combinations of n and hanoiValue
    for (0..1000) |n| {
        for (0..20) |hanoiValue| {
            var count: i32 = 0;
            // Count occurrences of hanoiValue up to n
            for (0..n) |j| {
                if (hanoiValues[j] == hanoiValue) {
                    count += 1;
                }
            }

            var v: u32 = @intCast(hanoiValue);
            var m: u32 = @intCast(n);

            const incidenceCount = hanoi.get_incidence_count_of_hanoi_value_through_index(v, m);

            if (count != incidenceCount) {
                std.debug.print("Mismatch at n={}, hanoiValue={}, count={}, incidenceCount={}\n", .{ n, hanoiValue, count, incidenceCount });
            }
            // Use std.testing.expectEqual for assertion without a formatted message
            try std.testing.expectEqual(count, incidenceCount);
        }
    }
}

test "test_get_index_of_hanoi_value_next_incidence" {
    // Loop over hanoiValue from 1 to 5
    for (1..6) |hanoiValue| {
        // Loop over i from 0 to 4
        for (0..5) |i| {
            const v: u32 = @intCast(hanoiValue);
            const j: u32 = @intCast(i);

            const lb = hanoi.get_index_of_hanoi_value_nth_incidence(v, j);
            const upb = hanoi.get_index_of_hanoi_value_nth_incidence(v, j + 1);
            const ub: i32 = @intCast(upb);

            // Test for indices between lb and ub
            for (lb..upb) |index| {
                const k: i32 = @intCast(index);
                const result = hanoi.get_index_of_hanoi_value_next_incidence(v, k, 1);
                try std.testing.expectEqual(result, ub);
            }

            // Test for indices before lb
            for (0..lb) |index| {
                const k: i32 = @intCast(index);
                const result = hanoi.get_index_of_hanoi_value_next_incidence(v, k, 1);
                try std.testing.expect(result <= lb and lb < ub);
            }

            // Test for index immediately after ub
            const resultAfterUb = hanoi.get_index_of_hanoi_value_next_incidence(v, ub, 1);
            try std.testing.expect(resultAfterUb > ub);
        }
    }
}
