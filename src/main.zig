const std = @import("std");
const os = std.os;
const process = std.process;
const fmt = std.fmt;
const mem = std.mem;

const DRAFT_FILE_PATH = os.getenv("HOME") ++ "/projects/writing";

pub fn main() !void {
    // Get cmd line args
    var allocator = std.heap.page_allocator;
    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    // generate date
    const date = try getCurrentDate(&allocator);
    defer allocator.free(date);

    // if name provided in args, set name, else null
    var name: ?[]const u8 = null;
    if (args.len > 2) {
        name = args[2];
    }

    // generate the full file name
    const file_path = try generateFilePath(date, name);
    defer allocator.free(file_path);

    // if cmd from args is draft, create draft file
    if (mem.eql(u8, args[1], "draft")) {
        try createDraftFile(file_path);

        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}", .{file_path});
    }
}

fn getCurrentDate(allocator: *std.mem.Allocator) ![]const u8 {
    const time = try std.time.SystemTime.now();
    const local_datetime = try std.time.LocalDateTime.fromSystemTime(time);

    return try std.fmt.allocPrint(allocator, "{d:04}{d:02}{d:02}", .{
        local_datetime.year,
        local_datetime.month,
        local_datetime.day,
    });
}

fn fileWriteError(file_path: []const u8) noreturn {
    std.debug.print("ERROR: Failed to open {s}\n", .{file_path});
    os.exit(1);
}

fn createDraftFile(file_path: []const u8) !void {
    const file = try std.fs.createFileAbsolute(file_path, .{});
    defer file.close();

    try file.writeAll("---\n");
    try file.writeAll("title:\n");
    try file.writeAll("description:\n");
    try file.writeAll("date: YYYY-MM-DD\n");
    try file.writeAll("hero:\n");
    try file.writeAll("draft: true\n");
    try .file.writeAll("---\n");
}

fn generateFilePath(date: []const u8, name: ?[]const u8) ![]u8 {
    const file_name = if (name) |n| {
        try fmt.allocPrint(std.heap.page_allocator, "{s}_{s}.md", .{ date, n });
    } else {
        try fmt.allocPrint(std.heap.page_allocator, "{s}.md", .{date});
    };
    defer std.heap.page_allocator.free(file_name);

    const file_path = try std.fs.path.join(std.heap.page_allocator, &[_][]const u8{ DRAFT_FILE_PATH, file_name });
    return file_path;
}
