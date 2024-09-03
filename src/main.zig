const std = @import("std");
const stdout = std.io.getStdOut().writer();

const blue = "\x1b[34m";
const reset = "\x1b[0m";

pub fn getCpuModelName(alloc: std.mem.Allocator) ![]const u8 {
    var file = std.fs.cwd().openFile("/proc/cpuinfo", .{}) catch @panic("uwu1");
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    while (stream.readUntilDelimiterOrEofAlloc(alloc, '\n', 500) catch @panic("uwu6969")) |line| {
        defer alloc.free(line);
        if (std.mem.startsWith(u8, line, "model name")) {
            if (std.mem.indexOf(u8, line, ":")) |index| {
                const result = try alloc.dupe(u8, line[index + 2 ..]);
                return result;
            }
        }
    }

    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const cpumodelname = try getCpuModelName(allocator);
    defer allocator.free(cpumodelname);

    var buf = std.io.bufferedWriter(stdout);
    var w = buf.writer();

    try w.print(
        \\{1s}   ▗▄   ▗▄ ▄▖   {2s}
        \\{1s}  ▄▄🬸█▄▄▄🬸█▛ ▃  {2s} cpu model: {0s}
        \\{1s}    ▟▛    ▜▃▟🬕  {2s}
        \\{1s} 🬋🬋🬫█      █🬛🬋🬋 {2s}
        \\{1s}  🬷▛🮃▙    ▟▛    {2s}
        \\{1s}  🮃 ▟█🬴▀▀▀█🬴▀▀  {2s}
        \\{1s}   ▝▀ ▀▘   ▀▘   {2s}
    , .{ cpumodelname, blue, reset });
    try buf.flush();
}
