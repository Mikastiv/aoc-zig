const std = @import("std");

const input_file = @embedFile("../data/day7");

const File = struct {
    name: []const u8,
    size: usize,

    fn fromString(str: []const u8) !File {
        var tokens = std.mem.tokenizeScalar(u8, str, ' ');
        const size = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const name = tokens.next().?;

        return .{
            .name = name,
            .size = size,
        };
    }
};

const Dir = struct {
    name: []const u8,
    dirs: std.ArrayList(Dir),
    files: std.ArrayList(File),
    parent: ?*Dir = null,

    fn fromString(str: []const u8, allocator: std.mem.Allocator) Dir {
        var tokens = std.mem.tokenizeScalar(u8, str, ' ');
        _ = tokens.next();

        const name = tokens.next().?;

        return .{
            .name = name,
            .dirs = std.ArrayList(Dir).init(allocator),
            .files = std.ArrayList(File).init(allocator),
        };
    }

    fn add(self: *Dir, str: []const u8, allocator: std.mem.Allocator) !void {
        var tokens = std.mem.tokenizeScalar(u8, str, ' ');
        const part = tokens.peek().?;

        if (std.mem.eql(u8, part, "dir")) {
            var dir = Dir.fromString(str, allocator);
            dir.parent = self;
            try self.dirs.append(dir);
        } else {
            try self.files.append(try File.fromString(str));
        }
    }

    fn find(self: *const Dir, name: []const u8) ?*Dir {
        for (self.dirs.items) |*dir| {
            if (std.mem.eql(u8, dir.name, name)) {
                return dir;
            }
        }
        return null;
    }

    fn size(self: *const Dir) usize {
        var total_size: usize = 0;

        for (self.dirs.items) |dir| {
            total_size += dir.size();
        }

        for (self.files.items) |file| {
            total_size += file.size;
        }

        return total_size;
    }

    fn findSize(self: *const Dir, total_size: *usize, comptime max: usize) void {
        const cur_size = self.size();
        if (cur_size <= max) total_size.* += cur_size;

        for (self.dirs.items) |dir| {
            dir.findSize(total_size, max);
        }
    }

    fn findToDelete(self: *const Dir, dir_size: *usize, space_to_free: usize) void {
        const cur_size = self.size();
        if (cur_size >= space_to_free) dir_size.* = @min(cur_size, dir_size.*);

        for (self.dirs.items) |dir| {
            dir.findToDelete(dir_size, space_to_free);
        }
    }
};

const Cmd = struct {
    name: []const u8,
    arg: ?[]const u8,

    fn fromString(str: []const u8) Cmd {
        var tokens = std.mem.tokenizeScalar(u8, str, ' ');
        _ = tokens.next();
        const name = tokens.next().?;
        const arg = tokens.next();

        return .{
            .name = name,
            .arg = arg,
        };
    }

    fn exec(self: *const Cmd, current: **Dir) void {
        if (!std.mem.eql(u8, self.name, "cd")) {
            return;
        }

        if (std.mem.eql(u8, self.arg.?, "..")) {
            current.* = current.*.parent.?;
        } else if (std.mem.eql(u8, current.*.name, self.arg.?)) {
            return;
        } else {
            current.* = current.*.find(self.arg.?).?;
        }
    }
};

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input_file, '\n');

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var root = Dir.fromString("dir /", alloc);

    var current = &root;
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "$")) {
            const cmd = Cmd.fromString(line);
            cmd.exec(&current);
        } else {
            try current.add(line, alloc);
        }
    }

    var total_size: usize = 0;
    root.findSize(&total_size, 100_000);
    std.debug.print("part 1 - {d}\n", .{total_size});

    total_size = root.size();
    const free_space = 70_000_000 - total_size;
    const space_to_free = 30_000_000 - free_space;
    root.findToDelete(&total_size, space_to_free);
    std.debug.print("part 2 - {d}\n", .{total_size});
}
