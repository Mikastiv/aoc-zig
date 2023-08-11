const std = @import("std");

const input_file = @embedFile("../data/day4");

const Range = struct {
    start: u32,
    end: u32,

    fn fromString(str: []const u8) !Range {
        var range = std.mem.splitScalar(u8, str, '-');

        const start = range.next().?;
        const end = range.next().?;

        return .{
            .start = try std.fmt.parseInt(u32, start, 10),
            .end = try std.fmt.parseInt(u32, end, 10),
        };
    }
};

const Pair = struct {
    r1: Range,
    r2: Range,

    fn fromString(str: []const u8) !Pair {
        var pairs = std.mem.splitScalar(u8, str, ',');

        const p1 = pairs.next().?;
        const p2 = pairs.next().?;

        return .{
            .r1 = try Range.fromString(p1),
            .r2 = try Range.fromString(p2),
        };
    }

    fn contains(self: Pair) bool {
        return (self.r1.start >= self.r2.start and self.r1.end <= self.r2.end) or
            (self.r2.start >= self.r1.start and self.r2.end <= self.r1.end);
    }

    fn overlap(self: Pair) bool {
        return (self.r1.start <= self.r2.end and self.r1.end >= self.r2.start) or
            (self.r2.start <= self.r1.end and self.r2.end >= self.r1.start);
    }
};

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, input_file, '\n');

    var contains: u32 = 0;
    var overlap: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const pair = try Pair.fromString(line);

        if (pair.contains()) contains += 1;
        if (pair.overlap()) overlap += 1;
    }

    std.debug.print("part 1 - {d}\n", .{contains});
    std.debug.print("part 2 - {d}\n", .{overlap});
}
