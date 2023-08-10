const std = @import("std");

const input_file = "data/day1";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(input_file, .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const input = try file.readToEndAlloc(alloc, 1 * 1024 * 1024);

    var it = std.mem.splitSequence(u8, input, "\n\n");

    var elves = std.ArrayList(u32).init(alloc);
    defer elves.deinit();

    while (it.next()) |snacks| {
        if (snacks.len == 0) continue;

        var snacks_it = std.mem.splitScalar(u8, snacks, '\n');

        var sum: u32 = 0;
        while (snacks_it.next()) |snack| {
            if (snack.len == 0) continue;
            sum += try std.fmt.parseInt(u32, snack, 10);
        }

        try elves.append(sum);
    }

    std.sort.pdq(u32, elves.items, {}, std.sort.desc(u32));

    std.debug.print("part 1 - {d}\n", .{elves.items[0]});
    std.debug.print("part 2 - {d}\n", .{elves.items[0] + elves.items[1] + elves.items[2]});
}
