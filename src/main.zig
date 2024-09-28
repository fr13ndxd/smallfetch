const std = @import("std");
const builtin = @import("builtin");

const sysinfo = @import("sysinfo.zig");
// \x1b[30m  // black (color 0)
// \x1b[31m  // red (color 1)
// \x1b[32m  // green (color 2)
// \x1b[33m  // yellow (color 3)
// \x1b[34m  // blue (color 4)
// \x1b[35m  // magenta (color 5)
// \x1b[36m  // cyan (color 6)
// \x1b[37m  // white (color 7)
// \x1b[0m  // reset color

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

    const distro = sysinfo.getOsName(buf[0..]) catch @panic("failed to get os name");
    const kernel_version = sysinfo.getKernelVersion(buf[0..]) catch @panic("failed to get kernel version");
    const shell = sysinfo.getShell() catch @panic("failed to get shell");
    const terminal = sysinfo.getTermianl() catch @panic("failed to get terminal");
    const memory = sysinfo.getRam(buf[500..]) catch @panic("failed to get memory usage");
    const uptime = try sysinfo.getUptime(buf[1000..]);

    //   ▗▄   ▗▄ ▄▖
    //  ▄▄🬸█▄▄▄🬸█▛ ▃
    //    ▟▛    ▜▃▟🬕
    // 🬋🬋🬫█      █🬛🬋🬋
    //  🬷▛🮃▙    ▟▛
    //  🮃 ▟█🬴▀▀▀█🬴▀▀
    //   ▝▀ ▀▘   ▀▘

    const stdout = std.io.getStdOut().writer();
    var bufw = std.io.bufferedWriter(stdout);
    var w = bufw.writer();

    //  $(red) \n $(green) \n $(yellow) \n $(blue) \n $(magenta) \n $(cyan) \n $(white) \n $(black)"
    //  $(9s) \n $(10s) \n $(11s) \n $(0s) \n $(magenta) \n $(cyan) \n $(white) \n $(black)"
    try w.print(
        \\{0s}   ▗▄   ▗▄ ▄▖   {1s} ╭────┤ {0s}{3s}{1s} ├───╮
        \\{0s}  ▄▄🬸█▄▄▄🬸█▛ ▃  {1s}{6s}  {1s} {2s}
        \\{0s}    ▟▛    ▜▃▟🬕  {1s}{6s}  {1s} {4s}
        \\{0s} 🬋🬋🬫█      █🬛🬋🬋 {1s}{6s}  {1s} {5s}
        \\{0s}  🬷▛🮃▙    ▟▛    {1s}{6s} 󰍛 {1s} {7s}
        \\{0s}  🮃 ▟█🬴▀▀▀█🬴▀▀  {1s}{6s} 󰔛 {1s} {8s}
        \\{0s}   ▝▀ ▀▘   ▀▘   {1s} ╰───────────────────────────────╯
        \\                     {9s}  {10s}  {11s}  {0s}  {12s}  {6s}  {13s}  {14s} {1s}
    , .{ blue, reset, kernel_version, distro, shell, terminal, cyan, memory, uptime, red, green, yellow, magenta, white, black });
    try bufw.flush();
}
