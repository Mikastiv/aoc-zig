const std = @import("std");

const input_file = @embedFile("../data/day9");

const Pos = struct {
    x: i32,
    y: i32,
};

const Vec = Pos;

const PosSet = std.AutoHashMap(Pos, void);

const Dir = enum {
    up,
    down,
    left,
    right,
};

const Move = struct {
    dir: Dir,
    amt: u32,

    fn fromString(str: []const u8) !Move {
        var it = std.mem.tokenizeScalar(u8, str, ' ');

        const dir: Dir = switch (it.next().?[0]) {
            'U' => .up,
            'D' => .down,
            'L' => .left,
            'R' => .right,
            else => unreachable,
        };
        const amt = try std.fmt.parseInt(u32, it.next().?, 10);

        return .{
            .dir = dir,
            .amt = amt,
        };
    }
};

fn applyMove(dst: *Pos, dir: Dir) void {
    switch (dir) {
        .up => dst.y += 1,
        .down => dst.y -= 1,
        .left => dst.x += 1,
        .right => dst.x -= 1,
    }
}

fn calculateDelta(a: Pos, b: Pos) Vec {
    return .{
        .x = a.x - b.x,
        .y = a.y - b.y,
    };
}

fn needsMove(delta: Vec) bool {
    return delta.x > 1 or delta.y > 1 or delta.x < -1 or delta.y < -1;
}

fn moveTail(tail: *Pos, delta: Vec) void {
    if (delta.x != 0) {
        tail.x += if (delta.x > 0) 1 else -1;
    }
    if (delta.y != 0) {
        tail.y += if (delta.y > 0) 1 else -1;
    }
}

fn processMove(head: *Pos, tail: *Pos, dir: Dir, comptime apply: bool) void {
    if (apply) applyMove(head, dir);
    const delta = calculateDelta(head.*, tail.*);
    if (needsMove(delta)) {
        moveTail(tail, delta);
    }
}

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input_file, '\n');

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var seen1 = PosSet.init(alloc);
    var seen2 = PosSet.init(alloc);

    const knot_count = 10;
    var knots = try std.BoundedArray(Pos, knot_count).init(knot_count);
    for (knots.slice()) |*knot| {
        knot.* = .{ .x = 0, .y = 0 };
    }
    try seen1.put(knots.get(0), {});
    try seen2.put(knots.get(0), {});

    while (lines.next()) |line| {
        const move = try Move.fromString(line);
        for (0..move.amt) |_| {
            inline for (0..knot_count - 1) |i| {
                processMove(&knots.slice()[i], &knots.slice()[i + 1], move.dir, i == 0);
            }
            try seen1.put(knots.get(1), {});
            try seen2.put(knots.get(9), {});
        }
    }

    var it = seen1.iterator();
    var count: usize = 0;
    while (it.next()) |_| {
        count += 1;
    }
    std.debug.print("part 1 - {d}\n", .{count});

    it = seen2.iterator();
    count = 0;
    while (it.next()) |_| {
        count += 1;
    }
    std.debug.print("part 2 - {d}\n", .{count});
}
