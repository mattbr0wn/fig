const std = @import("std");
const os = std.os;
const process = std.process;
const fmt = std.fmt;
const mem = std.mem;

const WriteError = error{
    CreateFailed,
    WriteFailed,
    MissingOutputPath,
};

const Command = enum {
    Draft,
    Unknown,
};

pub fn main() !void {
    // Get cmd line args
    const allocator = std.heap.page_allocator;
    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 3) {
        std.debug.print("Usage: {s} <command> [output_path]\n", .{args[0]});
        return;
    }

    const command = parseCommand(args[1]);
    const output_path: []const u8 = args[2];

    switch (command) {
        Command.Draft => try draftCmd(output_path),
        else => std.debug.print("Unknown command: {s}\n", .{args[1]}),
    }
}

fn parseCommand(arg: []const u8) Command {
    if (std.mem.eql(u8, arg, "draft")) {
        return Command.Draft;
    } else {
        return Command.Unknown;
    }
}

fn draftCmd(output_path: []const u8) !void {
    if (!std.fs.path.isAbsolute(output_path)) {
        std.debug.print("Error: Output path must be an absolute path\n", .{});
        return;
    }

    try createDraftFile(output_path);
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{?s}", .{output_path});
}

fn createDraftFile(file_path: []const u8) WriteError!void {
    const file = std.fs.createFileAbsolute(file_path, .{}) catch {
        std.debug.print("ERROR: Failed to create file {s}\n", .{file_path});
        return WriteError.CreateFailed;
    };
    defer file.close();

    const content =
        \\---
        \\title:
        \\description:
        \\date: YYYY-MM-DD
        \\hero:
        \\draft: true
        \\---
        \\
    ;

    file.writeAll(content) catch {
        std.debug.print("ERROR: Failed to write to file {s}\n", .{file_path});
        return WriteError.WriteFailed;
    };
}
