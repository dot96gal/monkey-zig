const std = @import("std");
const Token = @import("monkey.zig").Token;
const Lexer = @import("monkey.zig").Lexer;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const input = "+=";
    var lexer = Lexer.init(input);
    defer lexer.deinit();

    while (true) {
        const token = lexer.nextToken();
        try stdout.print("{}\n", .{token});

        if (token == Token.eof) {
            break;
        }
    }
}

comptime {
    std.testing.refAllDecls(@This());
}
