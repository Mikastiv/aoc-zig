const std = @import("std");

const input_file = @embedFile("../data/day5");

const Stacks = std.BoundedArray(std.BoundedArray(u8, 64), 16);

fn stackCount(crates_input: []const u8) usize {
    var lines = std.mem.splitBackwardsScalar(u8, crates_input, '\n');
    const crates_numbers = lines.next().?;

    var numbers = std.mem.tokenizeScalar(u8, crates_numbers, ' ');
    var count: usize = 0;
    while (numbers.next()) |_| {
        count += 1;
    }
    return count;
}

fn initStacks(crates_input: []const u8, count: usize) !Stacks {
    var stacks = try Stacks.init(count);
    for (&stacks.buffer) |*stack| {
        stack.* = try std.BoundedArray(u8, 64).init(0);
    }

    var lines = std.mem.splitBackwardsScalar(u8, crates_input, '\n');
    _ = lines.next();

    while (lines.next()) |line| {
        var i: u32 = 1;
        while (i < line.len) : (i += 4) {
            if (std.ascii.isAlphabetic(line[i])) {
                try stacks.buffer[i / 4].append(line[i]);
            }
        }
    }

    return stacks;
}

const Move = struct {
    src: u8,
    dst: u8,
    count: u8,

    fn fromString(str: []const u8) !Move {
        var tokens = std.mem.tokenizeScalar(u8, str, ' ');

        _ = tokens.next();
        const count = try std.fmt.parseInt(u8, tokens.next().?, 10);
        _ = tokens.next();
        const src = try std.fmt.parseInt(u8, tokens.next().?, 10);
        _ = tokens.next();
        const dst = try std.fmt.parseInt(u8, tokens.next().?, 10);

        return .{
            .src = src - 1,
            .dst = dst - 1,
            .count = count,
        };
    }
};

fn initMoves(moves_input: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Move) {
    var lines = std.mem.tokenizeScalar(u8, moves_input, '\n');

    var moves = std.ArrayList(Move).init(allocator);

    while (lines.next()) |line| {
        const move = try Move.fromString(line);
        try moves.append(move);
    }

    return moves;
}

fn processMove(stacks: *Stacks, move: Move) !void {
    for (0..move.count) |_| {
        const letter = stacks.buffer[move.src].pop();
        try stacks.buffer[move.dst].append(letter);
    }
}

fn processMove1(stacks: *Stacks, move: Move) !void {
    const boxes = stacks.buffer[move.src].constSlice();
    const len = stacks.buffer[move.src].len;
    const slice = boxes[len - move.count ..];
    try stacks.buffer[move.dst].appendSlice(slice);
    try stacks.buffer[move.src].resize(len - slice.len);
}

pub fn main() !void {
    var sections = std.mem.tokenizeSequence(u8, input_file, "\n\n");
    const crates_input = sections.next().?;
    const moves_input = sections.next().?;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const count = stackCount(crates_input);
    var stacks = try initStacks(crates_input, count);
    var moves = try initMoves(moves_input, alloc);

    {
        var stacks_1 = stacks;

        for (moves.items) |move| {
            try processMove(&stacks_1, move);
        }

        std.debug.print("part 1 - ", .{});
        for (stacks_1.constSlice()) |stack| {
            std.debug.print("{c}", .{stack.get(stack.len - 1)});
        }
        std.debug.print("\n", .{});
    }

    {
        var stacks_1 = stacks;

        for (moves.items) |move| {
            try processMove1(&stacks_1, move);
        }

        std.debug.print("part 2 - ", .{});
        for (stacks_1.constSlice()) |stack| {
            std.debug.print("{c}", .{stack.get(stack.len - 1)});
        }
        std.debug.print("\n", .{});
    }
}
