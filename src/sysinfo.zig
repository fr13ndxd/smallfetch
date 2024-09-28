const std = @import("std");

pub fn getOsName(buf: []u8) ![]const u8 {
    var file = try std.fs.openFileAbsolute("/etc/os-release", .{});
    defer file.close();
    _ = try file.readAll(buf[0..]);

    const index_start = std.mem.indexOf(u8, buf, "PRETTY_NAME").?;
    const index_end = index_start + (std.mem.indexOf(u8, buf[index_start..], "\n").?);

    return buf[index_start + 13 .. index_end - 1];
}

pub fn getKernelVersion(buf: []u8) ![]const u8 {
    var file = try std.fs.openFileAbsolute("/proc/version", .{});
    defer file.close();
    _ = try file.readAll(buf[0..]);
    var e = std.mem.splitSequence(u8, buf, " ");
    _ = e.next();
    _ = e.next();

    return e.next().?;
}

pub fn getUptime(buf: []u8) ![]const u8 {
    var file = try std.fs.openFileAbsolute("/proc/uptime", .{});
    defer file.close();
    _ = try file.readAll(buf[0..]);
    const index_end = std.mem.indexOf(u8, buf, " ").?;
    const uptime = buf[0..index_end];

    const uptime_seconds = try std.fmt.parseFloat(f32, uptime);
    var uptime_minutes = @trunc(uptime_seconds / 60);
    const uptime_days = @trunc(uptime_seconds / 86400);
    const uptime_hours = @divTrunc(uptime_minutes, 60);
    uptime_minutes = @rem(uptime_minutes, 60);
    @memset(buf[0..], 0);

    var at: usize = 0;
    if (uptime_days > 0) {
        const e = try std.fmt.bufPrint(buf[at..], "{d} days, ", .{uptime_days});
        at = e.len;
    }
    if (uptime_hours > 0) {
        const e = try std.fmt.bufPrint(buf[at..], "{d} hours{s}", .{ uptime_hours, if (uptime_minutes > 0) ", " else "" });
        at += e.len;
    }
    if (uptime_minutes > 0) {
        _ = try std.fmt.bufPrint(buf[at..], "{d} mins", .{uptime_minutes});
    }

    const result = buf[0..];
    return result;
}

pub fn getRam(buf: []u8) ![]const u8 {
    var file = try std.fs.openFileAbsolute("/proc/meminfo", .{});
    defer file.close();
    _ = try file.readAll(buf);
    _ = std.mem.replace(u8, buf, " ", "", buf);
    // MemTotal:....xxxxx kB
    // MemAvailable:....  kB

    // mem total
    // MemTotal:...xxxxxx kB
    const index_start = std.mem.indexOf(u8, buf, "MemTotal:").?;
    const index_end = index_start + (std.mem.indexOf(u8, buf[index_start..], "\n").?);
    const memtotal = buf[index_start + 9 .. index_end - 2];

    // mem available
    // MemAvailable: ...xxx kB
    const index_start2 = std.mem.indexOf(u8, buf, "Available:").?;
    const index_end2 = index_start2 + (std.mem.indexOf(u8, buf[index_start2..], "\n").?);
    const memavailable = buf[index_start2 + 10 .. index_end2 - 2];

    @setFloatMode(.optimized);
    const hello = 1024 * 1024;
    const memtotal_int = try std.fmt.parseFloat(f64, memtotal) / hello;
    const memavailable_int = try std.fmt.parseFloat(f64, memavailable) / hello;

    const memfree = (memtotal_int - memavailable_int);
    const percent = (memfree / memtotal_int) * 100;
    const result = std.fmt.bufPrint(buf, "{d:.2}GiB / {d:.2}GiB ({d:.1}%)", .{ memfree, memtotal_int, percent });
    return result;
}

pub fn getTermianl() ![]const u8 {
    for (std.os.environ) |line| {
        const ln = std.mem.span(line);
        if (std.mem.startsWith(u8, ln, "TERM_PROGRAM=")) {
            return ln[13..];
        }
    }

    return "not found";
}
pub fn getShell() ![]const u8 {
    for (std.os.environ) |line| {
        const ln = std.mem.span(line);
        if (std.mem.startsWith(u8, ln, "SHELL=")) {
            const index = std.mem.lastIndexOf(u8, ln, "/").? + 1;
            return ln[index..];
        }
    }

    return "not found";
}
