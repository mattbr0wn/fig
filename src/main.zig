const std = @import("std");
const os = std.os;
const process = std.process;
const fmt = std.fmt;
const mem = std.mem;
const draft = @import("cmd/draft.zig");
const tests = std.testing;

const Command = enum {
    Draft,
    Help,
    Unknown,
};

pub fn main() !void {
    // Get cmd line args
    var buffer: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 3) {
        helpMenu();
        return;
    }

    const command = parseCommand(args[1]);

    switch (command) {
        Command.Draft => {
            const file_name: []const u8 = args[2];
            defer draft.draftCmd(file_name) catch {
                std.process.exit(1);
            };
        },
        Command.Help => helpMenu(),
        else => std.debug.print("Unknown command: {s}\n", .{args[1]}),
    }
}

fn helpMenu() void {
    std.debug.print(
        \\
        \\Usage:  fig <command> [output_file_name]
        \\
        \\Commands:
        \\
        \\  draft      Create a draft article for mateocafe.com
        \\
    , .{});
}

fn parseCommand(arg: []const u8) Command {
    if (std.mem.eql(u8, arg, "draft")) {
        return Command.Draft;
    } else if (std.mem.eql(u8, arg, "help")) {
        return Command.Help;
    } else {
        return Command.Unknown;
    }
}

test "parse draft command" {
    const cmd = parseCommand("draft");
    try tests.expectEqual(Command.Draft, cmd);
}

test "parse help command" {
    const cmd = parseCommand("help");
    try tests.expectEqual(Command.Help, cmd);
}

test "parse unknown command" {
    const cmd = parseCommand("any");
    try tests.expectEqual(Command.Unknown, cmd);
}
