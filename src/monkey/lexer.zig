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

    pub fn nextToken(self: *Self) Token {
        self.skipWhitespace();

        const token: Token = switch (self.ch) {
            '=' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk Token.equal;
                } else {
                    break :blk Token.assign;
                }
            },
            '+' => Token.plus,
            '-' => Token.minus,
            '!' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk Token.not_equal;
                } else {
                    break :blk Token.bang;
                }
            },
            '*' => Token.asterisk,
            '/' => Token.slash,
            '<' => Token.less_than,
            '>' => Token.greater_than,
            ',' => Token.comma,
            ';' => Token.semicolon,
            '(' => Token.left_paren,
            ')' => Token.right_paren,
            '{' => Token.left_brace,
            '}' => Token.right_brace,
            0 => Token.eof,
            else => {
                if (self.isLetter(self.ch)) {
                    const identifier = self.readIdentifier();
                    return Token.lookup_identifier(identifier);
                } else if (self.isDigit(self.ch)) {
                    const number = self.readNumber();
                    return Token{ .integer = number };
                } else {
                    return Token.illegal;
                }
            },
        };

        self.readChar();

        return token;
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

    fn peekChar(self: Self) u8 {
        if (self.readPosition >= self.input.len) {
            return 0;
        } else {
            return self.input[self.readPosition];
        }
    }

    fn readIdentifier(self: *Self) []const u8 {
        const position = self.position;
        while (self.isLetter(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    fn readNumber(self: *Self) []const u8 {
        const position = self.position;
        while (self.isDigit(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    fn skipWhitespace(self: *Self) void {
        while (self.isWhitespace(self.ch)) {
            self.readChar();
        }
    }

    fn isWhitespace(_: Self, ch: u8) bool {
        return switch (ch) {
            ' ', '\t', '\r', '\n' => true,
            else => false,
        };
    }

    fn isLetter(_: Self, ch: u8) bool {
        return switch (ch) {
            'a'...'z', 'A'...'Z', '_' => true,
            else => false,
        };
    }

    fn isDigit(_: Self, ch: u8) bool {
        return switch (ch) {
            '0'...'9' => true,
            else => false,
        };
    }
};

test "Lexer.nextToken" {
    const TestCase = struct {
        input: []const u8,
        expected_tokens: []const Token,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "=+,;(){}",
            .expected_tokens = &.{
                Token.assign,
                Token.plus,
                Token.comma,
                Token.semicolon,
                Token.left_paren,
                Token.right_paren,
                Token.left_brace,
                Token.right_brace,
                Token.eof,
            },
        },
        .{
            .input =
            \\let five = 5;
            \\let ten = 10;
            \\
            \\let add = fn(x, y) {
            \\  x + y;
            \\};
            \\let result = add(five, ten);
            ,
            .expected_tokens = &.{
                Token.let,
                Token{ .identifier = "five" },
                Token.assign,
                Token{ .integer = "5" },
                Token.semicolon,
                Token.let,
                Token{ .identifier = "ten" },
                Token.assign,
                Token{ .integer = "10" },
                Token.semicolon,
                Token.let,
                Token{ .identifier = "add" },
                Token.assign,
                Token.function,
                Token.left_paren,
                Token{ .identifier = "x" },
                Token.comma,
                Token{ .identifier = "y" },
                Token.right_paren,
                Token.left_brace,
                Token{ .identifier = "x" },
                Token.plus,
                Token{ .identifier = "y" },
                Token.semicolon,
                Token.right_brace,
                Token.semicolon,
                Token.let,
                Token{ .identifier = "result" },
                Token.assign,
                Token{ .identifier = "add" },
                Token.left_paren,
                Token{ .identifier = "five" },
                Token.comma,
                Token{ .identifier = "ten" },
                Token.right_paren,
                Token.semicolon,
                Token.eof,
            },
        },
        .{
            .input =
            \\!-/*5;
            \\5 < 10 > 5;
            ,
            .expected_tokens = &.{
                Token.bang,
                Token.minus,
                Token.slash,
                Token.asterisk,
                Token{ .integer = "5" },
                Token.semicolon,
                Token{ .integer = "5" },
                Token.less_than,
                Token{ .integer = "10" },
                Token.greater_than,
                Token{ .integer = "5" },
                Token.semicolon,
                Token.eof,
            },
        },
        .{
            .input =
            \\if (5 < 10) {
            \\    return true;
            \\} else {
            \\    return false;
            \\}
            ,
            .expected_tokens = &.{
                Token.keyword_if,
                Token.left_paren,
                Token{ .integer = "5" },
                Token.less_than,
                Token{ .integer = "10" },
                Token.right_paren,
                Token.left_brace,
                Token.keyword_return,
                Token.true,
                Token.semicolon,
                Token.right_brace,
                Token.keyword_else,
                Token.left_brace,
                Token.keyword_return,
                Token.false,
                Token.semicolon,
                Token.right_brace,
                Token.eof,
            },
        },
        .{
            .input =
            \\10 == 10;
            \\10 != 9;
            ,
            .expected_tokens = &.{
                Token{ .integer = "10" },
                Token.equal,
                Token{ .integer = "10" },
                Token.semicolon,
                Token{ .integer = "10" },
                Token.not_equal,
                Token{ .integer = "9" },
                Token.semicolon,
                Token.eof,
            },
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init(tt.input);
        defer lexer.deinit();

        for (tt.expected_tokens) |expected_token| {
            const token = lexer.nextToken();
            try std.testing.expect(expected_token.equals(token));
        }
    }
}

test "Lexer.readChar" {
    const TestCase = struct {
        input: []const u8,
        expected: []const u8,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "abc",
            .expected = &.{
                'a',
                'b',
                'c',
                0,
            },
        },
        .{
            .input = "abc d",
            .expected = &.{
                'a',
                'b',
                'c',
                ' ',
                'd',
                0,
            },
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init(tt.input);
        defer lexer.deinit();

        for (tt.expected) |expected_ch| {
            try std.testing.expectEqual(expected_ch, lexer.ch);
            lexer.readChar();
        }
    }
}

test "Lexer.peekChar" {
    const TestCase = struct {
        input: []const u8,
        expected: []const u8,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "abc",
            .expected = &.{
                'b',
                'c',
                0,
            },
        },
        .{
            .input = "abc d",
            .expected = &.{
                'b',
                'c',
                ' ',
                'd',
                0,
            },
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init(tt.input);
        defer lexer.deinit();

        for (tt.expected) |expected_ch| {
            const actual = lexer.peekChar();
            try std.testing.expectEqual(expected_ch, actual);
            lexer.readChar();
        }
    }
}

test "Lexer.readIdentifier" {
    const TestCase = struct {
        input: []const u8,
        expected: []const u8,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "let",
            .expected = "let",
        },
        .{
            .input = "fn",
            .expected = "fn",
        },
        .{
            .input = "five",
            .expected = "five",
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init(tt.input);
        defer lexer.deinit();

        const actual = lexer.readIdentifier();
        try std.testing.expectEqual(tt.expected, actual);
    }
}

test "Lexer.readNumber" {
    const TestCase = struct {
        input: []const u8,
        expected: []const u8,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "1",
            .expected = "1",
        },
        .{
            .input = "12",
            .expected = "12",
        },
        .{
            .input = "123",
            .expected = "123",
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init(tt.input);
        defer lexer.deinit();

        const actual = lexer.readNumber();
        try std.testing.expectEqual(tt.expected, actual);
    }
}

test "Lexer.skipWhitespace" {
    const TestCase = struct {
        input: []const u8,
        expected: []const u8,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "abc",
            .expected = &.{
                'a',
                'b',
                'c',
                0,
            },
        },
        .{
            .input = "  a \t b \r c \n d  ",
            .expected = &.{
                'a',
                'b',
                'c',
                'd',
                0,
            },
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init(tt.input);
        defer lexer.deinit();

        for (tt.expected) |expected_ch| {
            lexer.skipWhitespace();
            try std.testing.expectEqual(expected_ch, lexer.ch);
            lexer.readChar();
        }
    }
}

test "Lexer.isWhitespace" {
    const TestCase = struct {
        input: u8,
        expected: bool,
    };

    const tests: []const TestCase = &.{
        .{
            .input = ' ',
            .expected = true,
        },
        .{
            .input = '\t',
            .expected = true,
        },
        .{
            .input = '\n',
            .expected = true,
        },
        .{
            .input = '\r',
            .expected = true,
        },

        .{
            .input = 'a',
            .expected = false,
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init("");
        defer lexer.deinit();

        const actual = lexer.isWhitespace(tt.input);
        try std.testing.expectEqual(tt.expected, actual);
    }
}
test "Lexer.isLetter" {
    const TestCase = struct {
        input: u8,
        expected: bool,
    };

    const tests: []const TestCase = &.{
        .{
            .input = 'a',
            .expected = true,
        },
        .{
            .input = 'z',
            .expected = true,
        },
        .{
            .input = 'A',
            .expected = true,
        },
        .{
            .input = 'Z',
            .expected = true,
        },

        .{
            .input = '_',
            .expected = true,
        },
        .{
            .input = '0',
            .expected = false,
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init("");
        defer lexer.deinit();

        const actual = lexer.isLetter(tt.input);
        try std.testing.expectEqual(tt.expected, actual);
    }
}

test "Lexer.isDigit" {
    const TestCase = struct {
        input: u8,
        expected: bool,
    };

    const tests: []const TestCase = &.{
        .{
            .input = '0',
            .expected = true,
        },
        .{
            .input = '1',
            .expected = true,
        },
        .{
            .input = '2',
            .expected = true,
        },
        .{
            .input = '3',
            .expected = true,
        },

        .{
            .input = '4',
            .expected = true,
        },
        .{
            .input = '5',
            .expected = true,
        },
        .{
            .input = '6',
            .expected = true,
        },
        .{
            .input = '7',
            .expected = true,
        },
        .{
            .input = '8',
            .expected = true,
        },

        .{
            .input = '9',
            .expected = true,
        },
        .{
            .input = 'a',
            .expected = false,
        },
    };

    for (tests) |tt| {
        var lexer = Lexer.init("");
        defer lexer.deinit();

        const actual = lexer.isDigit(tt.input);
        try std.testing.expectEqual(tt.expected, actual);
    }
}
