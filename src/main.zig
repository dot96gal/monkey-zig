const std = @import("std");
const repl = @import("monkey.zig").repl;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    try repl.start(stdin, stdout);
}

comptime {
    std.testing.refAllDecls(@This());
}
