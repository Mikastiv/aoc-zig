const std = @import("std");

const input_file = @embedFile("../data/day8");

fn countLines(str: []const u8) usize {
    var lines = std.mem.tokenizeScalar(u8, str, '\n');
    var count: usize = 0;
    while (lines.next()) |_| {
        count += 1;
    }
    return count;
}

fn isVisible(trees: *std.ArrayList(std.ArrayList(u8)), x: usize, y: usize) bool {
    const height = trees.items[y].items[x];
    const row_len = trees.items[y].items.len;
    const col_len = trees.items.len;

    for (trees.items[y].items[0..x]) |it| {
        if (height <= it) break;
    } else {
        return true;
    }

    for (trees.items[y].items[x + 1 .. row_len]) |it| {
        if (height <= it) break;
    } else {
        return true;
    }

    for (trees.items[0..y]) |it| {
        if (height <= it.items[x]) break;
    } else {
        return true;
    }

    for (trees.items[y + 1 .. col_len]) |it| {
        if (height <= it.items[x]) break;
    } else {
        return true;
    }

    return false;
}

fn visibilityScore(trees: *std.ArrayList(std.ArrayList(u8)), x: usize, y: usize) usize {
    const height = trees.items[y].items[x];
    const row_len = trees.items[y].items.len;
    const col_len = trees.items.len;

    var score_right: usize = 0;
    for (trees.items[y].items[x + 1 .. row_len]) |it| {
        score_right += 1;
        if (height <= it) {
            break;
        }
    }

    var score_left: usize = 0;
    var it_left = std.mem.reverseIterator(trees.items[y].items[0..x]);
    while (it_left.next()) |it| {
        score_left += 1;
        if (height <= it) {
            break;
        }
    }

    var score_bottom: usize = 0;
    for (trees.items[y + 1 .. col_len]) |it| {
        score_bottom += 1;
        if (height <= it.items[x]) {
            break;
        }
    }

    var score_top: usize = 0;
    var it_top = std.mem.reverseIterator(trees.items[0..y]);
    while (it_top.next()) |it| {
        score_top += 1;
        if (height <= it.items[x]) {
            break;
        }
    }

    return score_right * score_left * score_bottom * score_top;
}

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input_file, '\n');

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const line_count = countLines(input_file);
    const line_len = lines.peek().?.len;

    var trees = try std.ArrayList(std.ArrayList(u8)).initCapacity(alloc, line_count);
    for (0..line_count) |_| {
        try trees.append(try std.ArrayList(u8).initCapacity(alloc, line_len));
    }

    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        for (line) |char| {
            try trees.items[i].append(char);
        }
    }

    var sum: usize = 0;
    sum += line_count * 2;
    sum += (line_len - 2) * 2;

    var score: usize = 0;

    var y: usize = 1;
    while (y < line_count - 1) : (y += 1) {
        var x: usize = 1;
        while (x < line_len - 1) : (x += 1) {
            if (isVisible(&trees, x, y)) {
                sum += 1;
            }
            const vis = visibilityScore(&trees, x, y);
            if (vis > score) {
                score = vis;
            }
        }
    }

    std.debug.print("part 1 - {d}\n", .{sum});
    std.debug.print("part 2 - {d}\n", .{score});
}
