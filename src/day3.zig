const std = @import("std");

const input_file = @embedFile("../data/day3");

fn index(char: u8) u6 {
    const ret = switch (char) {
        'a'...'z' => char - 'a' + 1,
        'A'...'Z' => char - 'A' + 27,
        else => unreachable,
    };
    return @truncate(ret);
}

fn maskToChar(idx: u64) u8 {
    const i = @ctz(idx);
    return switch (i) {
        1...26 => 'a' + i - 1,
        27...52 => 'A' + i - 27,
        else => unreachable,
    };
}

fn findCommon(a: []const u8, b: []const u8) ?u8 {
    var letters: u64 = 0;

    for (a) |c| {
        letters |= @as(u64, 1) << index(c);
    }

    for (b) |c| {
        const bit = @as(u64, 1) << index(c);
        if (letters & bit != 0) {
            return c;
        }
    }

    return null;
}

fn findCommon3(a: []const u8, b: []const u8, c: []const u8) u8 {
    var letters1: u64 = 0;
    var letters2: u64 = 0;
    var letters3: u64 = 0;

    for (a) |d| {
        letters1 |= @as(u64, 1) << index(d);
    }

    for (b) |d| {
        letters2 |= @as(u64, 1) << index(d);
    }

    for (c) |d| {
        letters3 |= @as(u64, 1) << index(d);
    }

    const idx = letters1 & letters2 & letters3;
    const common = maskToChar(idx);

    return common;
}

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input_file, '\n');

    var sum: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const sack1 = line[0 .. line.len / 2];
        const sack2 = line[line.len / 2 ..];

        const common = findCommon(sack1, sack2);
        if (common) |u| {
            sum += index(u);
        }
    }
    std.debug.print("part 1 - {d}\n", .{sum});

    lines = std.mem.splitScalar(u8, input_file, '\n');

    sum = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const elf1 = line;
        const elf2 = lines.next().?;
        const elf3 = lines.next().?;

        const common = findCommon3(elf1, elf2, elf3);
        sum += index(common);
    }

    std.debug.print("part 2 - {d}\n", .{sum});
}
