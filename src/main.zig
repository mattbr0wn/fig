const std = @import("std");
const os = std.os;
const process = std.process;
const fmt = std.fmt;
const mem = std.mem;
const draft = @import("cmd/draft.zig");

const Command = enum {
    Draft,
    Help,
    Unknown,
};

pub fn main() !void {
    // Get cmd line args
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buffer[0..]);
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
            const output_path: []const u8 = args[2];
            draft.draftCmd(output_path) catch {
                std.process.exit(1);
            };
        },
        Command.Help => helpMenu(),
        else => std.debug.print("Unknown command: {s}\n", .{args[1]}),
    }
}

fn helpMenu() void {
    std.debug.print(
        \\Usage:  fig <command> [output_file_path]
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
