const std = @import("std");
const testing = std.testing;

const WriteError = error{
    CreateFailed,
    WriteFailed,
    InvalidOutputPath,
};

pub fn draftCmd(output_path: []const u8) !void {
    if (!std.fs.path.isAbsolute(output_path)) {
        std.debug.print("Error: Output path must be an absolute path\n", .{});
        return WriteError.InvalidOutputPath;
    }

    try createDraftFile(output_path);
    std.debug.print("Created file\n", .{});
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

//// TESTS ////
