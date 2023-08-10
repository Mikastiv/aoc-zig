const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const src_dir = "src";
    var dir = try std.fs.cwd().openIterableDir(src_dir, .{});
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        switch (entry.kind) {
            .file => {
                if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;

                const filename = try std.fs.path.join(b.allocator, &.{ src_dir, entry.name });
                defer b.allocator.free(filename);

                const exe = b.addExecutable(.{
                    .name = entry.name[0 .. entry.name.len - 4],
                    .root_source_file = .{ .path = filename },
                    .target = target,
                    .optimize = optimize,
                });

                b.installArtifact(exe);

                const run_cmd = b.addRunArtifact(exe);
                run_cmd.step.dependOn(b.getInstallStep());

                if (b.args) |args| {
                    run_cmd.addArgs(args);
                }

                const run_step = b.step(entry.name[0 .. entry.name.len - 4], "Run the day");
                run_step.dependOn(&run_cmd.step);
            },
            else => continue,
        }
    }
}
