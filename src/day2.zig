const std = @import("std");

const input_file = @embedFile("../data/day2");

const Choice = enum {
    rock,
    paper,
    scissors,

    fn points(self: Choice) u32 {
        return switch (self) {
            .rock => 1,
            .paper => 2,
            .scissors => 3,
        };
    }

    fn fromChar(char: u8) !Choice {
        return switch (char) {
            'A', 'X' => .rock,
            'B', 'Y' => .paper,
            'C', 'Z' => .scissors,
            else => error.InvalidChar,
        };
    }

    fn fromResult(choice: Choice, result: Result) Choice {
        return switch (choice) {
            .rock => switch (result) {
                .win => .paper,
                .loss => .scissors,
                .draw => .rock,
            },
            .paper => switch (result) {
                .win => .scissors,
                .loss => .rock,
                .draw => .paper,
            },
            .scissors => switch (result) {
                .win => .rock,
                .loss => .paper,
                .draw => .scissors,
            },
        };
    }
};

const Result = enum {
    win,
    loss,
    draw,

    fn points(self: Result) u32 {
        return switch (self) {
            .win => 6,
            .loss => 0,
            .draw => 3,
        };
    }

    fn fromGame(c1: Choice, c2: Choice) Result {
        return switch (c1) {
            .rock => switch (c2) {
                .rock => .draw,
                .paper => .loss,
                .scissors => .win,
            },
            .paper => switch (c2) {
                .rock => .win,
                .paper => .draw,
                .scissors => .loss,
            },
            .scissors => switch (c2) {
                .rock => .loss,
                .paper => .win,
                .scissors => .draw,
            },
        };
    }

    fn fromChar(char: u8) !Result {
        return switch (char) {
            'X' => .loss,
            'Y' => .draw,
            'Z' => .win,
            else => error.InvalidChar,
        };
    }
};

pub fn main() !void {
    @setEvalBranchQuota(64000);

    const result = comptime blk: {
        var game_it = std.mem.splitScalar(u8, input_file, '\n');

        var score1: u32 = 0;
        var score2: u32 = 0;
        while (game_it.next()) |game| {
            if (game.len == 0) continue;

            var choice_it = std.mem.splitScalar(u8, game, ' ');

            const choice1_slice = choice_it.next() orelse return error.InvalidGame;
            const choice2_slice = choice_it.next() orelse return error.InvalidGame;
            std.debug.assert(choice1_slice.len > 0 and choice2_slice.len > 0);

            const choice1 = try Choice.fromChar(choice1_slice[0]);
            const choice2 = try Choice.fromChar(choice2_slice[0]);

            score1 += Result.fromGame(choice2, choice1).points();
            score1 += choice2.points();

            const result = try Result.fromChar(choice2_slice[0]);
            score2 += result.points();
            score2 += Choice.fromResult(choice1, result).points();
        }
        break :blk .{ score1, score2 };
    };

    std.debug.print("part 1 - {d}\n", .{result[0]});
    std.debug.print("part 2 - {d}\n", .{result[1]});
}
