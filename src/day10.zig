const std = @import("std");

const input_file = @embedFile("../data/day10");

const Cpu = struct {
    x: i32 = 1,
    cycle: isize = 1,

    fn signalStrength(self: Cpu) isize {
        return self.x * self.cycle;
    }

    fn isSignalCycle(self: Cpu) bool {
        return self.cycle == 20 or (@rem(self.cycle - 20, 40) == 0 and self.cycle <= 220);
    }
};

const Crt = struct {
    const width = 40;
    const height = 6;

    pixels: std.BoundedArray(u8, width * height),

    fn init() !Crt {
        var crt = Crt{ .pixels = try std.BoundedArray(u8, width * height).init(width * height) };
        for (crt.pixels.slice()) |*char| {
            char.* = '.';
        }
        return crt;
    }

    fn putPixel(self: *Crt, x: usize, y: usize) void {
        const idx = y * width + x;
        if (idx >= self.pixels.len) return;
        self.pixels.set(idx, '#');
    }

    fn print(self: *Crt) void {
        for (0..height) |h| {
            std.debug.print("{s}\n", .{self.pixels.constSlice()[h * width .. h * width + width]});
        }
    }
};

const Ins = union(enum) {
    noop,
    addx: i32,

    fn fromString(str: []const u8) !Ins {
        var it = std.mem.tokenizeScalar(u8, str, ' ');

        const name = it.next().?;
        if (std.mem.eql(u8, name, "noop")) {
            return .noop;
        } else {
            const operand = try std.fmt.parseInt(i32, it.next().?, 10);
            return .{ .addx = operand };
        }
    }

    fn cycles(self: Ins) usize {
        return switch (self) {
            .noop => 1,
            .addx => 2,
        };
    }
};

fn shouldDraw(pos: i32, x: usize) !bool {
    const diff = pos - @as(i32, @intCast(x));
    return try std.math.absInt(diff) <= 1;
}

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input_file, '\n');

    var cpu = Cpu{};
    var crt = try Crt.init();
    var sum: isize = 0;
    var x: usize = 0;
    var y: usize = 0;
    while (lines.next()) |line| {
        const inst = try Ins.fromString(line);

        for (0..inst.cycles()) |_| {
            if (cpu.isSignalCycle()) sum += cpu.signalStrength();

            if (try shouldDraw(cpu.x, x)) crt.putPixel(x, y);

            x += 1;
            if (@rem(cpu.cycle, 40) == 0) {
                x = 0;
                y += 1;
            }

            cpu.cycle += 1;
        }

        if (Ins.addx == inst) {
            cpu.x += inst.addx;
        }
    }

    std.debug.print("part 1 - {d}\n", .{sum});
    std.debug.print("part 2\n", .{});
    crt.print();
}
