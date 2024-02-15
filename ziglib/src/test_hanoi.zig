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

test "test get_hanoi_value_index_offset" {
    try std.testing.expectEqual(hanoi.get_hanoi_value_index_offset(0), 0);
    try std.testing.expectEqual(hanoi.get_hanoi_value_index_offset(1), 1);
    try std.testing.expectEqual(hanoi.get_hanoi_value_index_offset(2), 3);
    try std.testing.expectEqual(hanoi.get_hanoi_value_index_offset(3), 7);
    try std.testing.expectEqual(hanoi.get_hanoi_value_index_offset(4), 15);
}

test "test_get_max_hanoi_value_through_index" {
    try std.testing.expectEqual(hanoi.get_max_hanoi_value_through_index(0), 0);
    try std.testing.expectEqual(hanoi.get_max_hanoi_value_through_index(1), 1);
    try std.testing.expectEqual(hanoi.get_max_hanoi_value_through_index(2), 1);
    try std.testing.expectEqual(hanoi.get_max_hanoi_value_through_index(3), 2);

    var hanoiValues: [1000]u32 = undefined;

    for (0..1000) |i| {
        const j: u32 = @intCast(i);
        hanoiValues[i] = hanoi.get_hanoi_value_at_index(j);
    }

    var maxValue: u32 = 0;
    for (0..1000) |n| {
        for (0..n + 1) |j| {
            if (hanoiValues[j] > maxValue) {
                maxValue = hanoiValues[j];
            }
        }
        const m: u32 = @intCast(n);
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

    for (0..1000) |i| {
        const j: u32 = @intCast(i);
        hanoiValues[i] = hanoi.get_hanoi_value_at_index(j);
    }

    for (0..1000) |n| {
        for (0..20) |hanoiValue| {
            var count: u32 = 0;
            for (0..n + 1) |j| {
                if (hanoiValues[j] == hanoiValue) {
                    count += 1;
                }
            }

            const v: u32 = @intCast(hanoiValue);
            const m: u32 = @intCast(n);

            const incidenceCount = hanoi.get_incidence_count_of_hanoi_value_through_index(v, m);

            try std.testing.expectEqual(count, incidenceCount);
        }
    }
}

test "test_get_index_of_hanoi_value_next_incidence" {
    for (1..6) |hanoiValue| {
        for (0..5) |i| {
            const v: u32 = @intCast(hanoiValue);
            const j: u32 = @intCast(i);

            const lb = hanoi.get_index_of_hanoi_value_nth_incidence(v, j);
            const ub = hanoi.get_index_of_hanoi_value_nth_incidence(v, j + 1);

            for (lb..ub) |index| {
                const k: u32 = @intCast(index);
                const result = hanoi.get_index_of_hanoi_value_next_incidence(v, k, 1);
                try std.testing.expectEqual(result, ub);
            }

            for (0..lb) |index| {
                const result = hanoi.get_index_of_hanoi_value_next_incidence(v, @intCast(index), 1);
                try std.testing.expect(result <= lb and lb < ub);
            }

            const resultAfterUb = hanoi.get_index_of_hanoi_value_next_incidence(v, ub, 1);
            try std.testing.expect(resultAfterUb > ub);
        }
    }
}
