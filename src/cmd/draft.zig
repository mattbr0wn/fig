const std = @import("std");
const testing = std.testing;
const fs = std.fs;
const mem = std.mem;

const WriteError = error{
    CreateFailed,
    WriteFailed,
    InvalidOutputPath,
};

pub fn draftCmd(file_name: []const u8) !void {
    var buffer: [256]u8 = undefined;
    const output_path = try getDraftFilePath(file_name, &buffer);

    if (!std.fs.path.isAbsolute(output_path)) {
        std.debug.print("Error: Output path must be an absolute path\n", .{});
        return WriteError.InvalidOutputPath;
    }

    try createDraftFile(output_path);
    std.debug.print("Created file\n", .{});
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{output_path});
}

fn getDraftFilePath(file_name: []const u8, buffer: *[256]u8) ![]const u8 {
    const home = std.posix.getenv("HOME") orelse {
        std.debug.print("HOME environment variable not found.\n", .{});
        return error.MissingHomeEnvVar;
    };

    const file_path = try std.fmt.bufPrint(buffer, "{s}/projects/writing/{s}.md", .{ home, file_name });
    return file_path;
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
