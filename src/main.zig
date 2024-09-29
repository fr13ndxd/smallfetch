const std = @import("std");
const builtin = @import("builtin");

const sysinfo = @import("sysinfo.zig");

const black = "\x1b[30m";
const red = "\x1b[91m";
const green = "\x1b[92m";
const yellow = "\x1b[93m";
const white = "\x1b[37m";
const blue = "\x1b[34m";
const pink = "\x1b[38;5;212m";
const magenta = "\x1b[35m";
const cyan = "\x1b[36m";
const reset = "\x1b[0m";

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    const distro = sysinfo.getOsName(allocator) catch @panic("failed to get os name");
    const kernel_version = sysinfo.getKernelVersion(allocator) catch @panic("failed to get kernel version");
    const shell = sysinfo.getShell() catch @panic("failed to get shell");
    const terminal = sysinfo.getTermianl() catch @panic("failed to get terminal");
    const memory = sysinfo.getRam(allocator) catch @panic("failed to get memory usage");
    const uptime = try sysinfo.getUptime(allocator);

    const stdout = std.io.getStdOut().writer();
    var bufw = std.io.bufferedWriter(stdout);
    var w = bufw.writer();

    try w.print("{1s}   ▗▄   ▗▄ ▄▖   {0s} ╭────┤ {1s}{2s}{0s} ├───╮\n", .{ reset, blue, distro });
    try w.print("{1s}  ▄▄🬸█▄▄▄🬸█▛ ▃  {0s}{2s}  {0s} {3s}\n", .{ reset, blue, cyan, kernel_version });
    try w.print("{1s}    ▟▛    ▜▃▟🬕  {0s}{2s}  {0s} {3s}\n", .{ reset, blue, cyan, shell });
    try w.print("{1s} 🬋🬋🬫█      █🬛🬋🬋 {0s}{2s}  {0s} {3s}\n", .{ reset, blue, cyan, terminal });
    try w.print("{1s}  🬷▛🮃▙    ▟▛    {0s}{2s} 󰍛 {0s} {3s}\n", .{ reset, blue, cyan, memory });
    try w.print("{1s}  🮃 ▟█🬴▀▀▀█🬴▀▀  {0s}{2s} 󰔛 {0s} {3s}\n", .{ reset, blue, cyan, uptime });
    try w.print("{1s}   ▝▀ ▀▘   ▀▘   {0s} ╰───────────────────────────────╯\n", .{ reset, blue });
    try w.print("                     {0s}  {1s}  {2s}  {3s}  {4s}  {5s}  {6s}  {7s} {0s}\n", .{
        red,
        green,
        yellow,
        blue,
        magenta,
        cyan,
        white,
        black,
    });
    try bufw.flush();
}
