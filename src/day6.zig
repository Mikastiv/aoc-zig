const std = @import("std");

const input_file = @embedFile("../data/day6");

fn letterMask(char: u8) u64 {
    const ret = switch (char) {
        'a'...'z' => char - 'a',
        'A'...'Z' => char - 'A' + 26,
        else => unreachable,
    };
    return @as(u64, 1) << @truncate(ret);
}

fn isUnique(slice: []const u8) bool {
    var letters: u64 = 0;

    for (slice) |char| {
        const mask = letterMask(char);
        if (letters & mask != 0) {
            return false;
        } else {
            letters |= mask;
        }
    }
    return true;
}

fn markerPosition(data: []const u8, comptime uniqueCount: u32) ?usize {
    var start: u32 = 0;
    while (start < data.len - uniqueCount) : (start += 1) {
        const slice = data[start .. start + uniqueCount];
        if (isUnique(slice)) return start + uniqueCount;
    }
    return null;
}

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input_file, '\n');
    const line = lines.next().?;

    const index1 = markerPosition(line, 4);
    const index2 = markerPosition(line, 14);

    std.debug.print("part 1 - {d}\n", .{index1.?});
    std.debug.print("part 2 - {d}\n", .{index2.?});
}
