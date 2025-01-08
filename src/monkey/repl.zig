const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Token = @import("token.zig").Token;

pub fn start(reader: anytype, writer: anytype) !void {
    const prompt = ">> ";
    var buffer: [1024]u8 = undefined;

    while (true) {
        try writer.print("{s}", .{prompt});
        const input = try reader.readUntilDelimiter(&buffer, '\n');

        var lexer = Lexer.init(input);
        defer lexer.deinit();

        while (true) {
            const token = lexer.nextToken();
            try writer.print("{}\n", .{token});

            if (token.equals(Token.eof)) {
                break;
            }
        }
    }
}
