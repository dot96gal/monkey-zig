const std = @import("std");
const Token = @import("token.zig").Token;

pub const Lexer = struct {
    input: []const u8,
    position: usize,
    readPosition: usize,
    ch: u8,

    const Self = @This();

    pub fn init(input: []const u8) Self {
        var lexer = Self{
            .input = input,
            .position = 0,
            .readPosition = 0,
            .ch = 0,
        };
        lexer.readChar();
        return lexer;
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    fn readChar(self: *Self) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
    }

    pub fn nextToken(self: *Self) Token {
        const token: Token = switch (self.ch) {
            '=' => Token.assign,
            '+' => Token.plus,
            ',' => Token.comma,
            ';' => Token.semicolon,
            '(' => Token.left_paren,
            ')' => Token.right_paren,
            '{' => Token.left_brace,
            '}' => Token.right_brace,
            0 => Token.eof,
            else => unreachable,
        };

        self.readChar();

        return token;
    }
};

test "test Lexer.nextToken" {
    const input = "=+,;(){}";

    const exptected_tokens = [_]Token{
        Token.assign,
        Token.plus,
        Token.comma,
        Token.semicolon,
        Token.left_paren,
        Token.right_paren,
        Token.left_brace,
        Token.right_brace,
        Token.eof,
    };

    var lexer = Lexer.init(input);
    defer lexer.deinit();

    for (exptected_tokens) |expected_token| {
        const token = lexer.nextToken();
        try std.testing.expectEqual(token, expected_token);
    }
}
