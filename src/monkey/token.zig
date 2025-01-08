const std = @import("std");

const TokenType = enum {
    illegal,
    eof,

    // Identifier + Literal
    identifier,
    integer,

    // Operator
    assign, // =
    plus, // +
    minus, // -
    bang, // !
    asterisk, // *
    slash, // /
    less_than, // <
    greater_than, // >
    equal, // ==
    not_equal, // !=

    // Delimiters
    comma, // ,
    semicolon, // ;
    left_paren, // (
    right_paren, // )
    left_brace, // {
    right_brace, // }

    // Keyword
    function, // fn
    let, // let
    true, // true
    false, // false
    keyword_if, // if
    keyword_else, // else
    keyword_return, // return
};

pub const Token = union(TokenType) {
    illegal: void,
    eof: void,

    // Identifier + Literal
    identifier: []const u8,
    integer: []const u8,

    // Operator
    assign: void,
    plus: void,
    minus: void,
    bang: void,
    asterisk: void,
    slash: void,
    less_than: void,
    greater_than: void,
    equal: void,
    not_equal: void,

    // Delimiters
    comma: void,
    semicolon: void,
    left_paren: void,
    right_paren: void,
    left_brace: void,
    right_brace: void,

    // Keyword
    function: void,
    let: void,
    true: void,
    false: void,
    keyword_if: void,
    keyword_else: void,
    keyword_return: void,

    const Self = @This();

    fn literal(self: Self) []const u8 {
        return switch (self) {
            .identifier => self.identifier,
            .integer => self.integer,
            else => "",
        };
    }

    fn equalsType(self: Self, other: Self) bool {
        return @as(TokenType, self) == @as(TokenType, other);
    }

    fn equalsLiteral(self: Self, other: Self) bool {
        return std.mem.eql(u8, self.literal(), other.literal());
    }

    pub fn equals(self: Self, other: Self) bool {
        return self.equalsType(other) and self.equalsLiteral(other);
    }

    pub fn lookup_identifier(identifier: []const u8) Self {
        if (std.mem.eql(u8, identifier, "let")) {
            return Token.let;
        } else if (std.mem.eql(u8, identifier, "fn")) {
            return Token.function;
        } else if (std.mem.eql(u8, identifier, "true")) {
            return Token.true;
        } else if (std.mem.eql(u8, identifier, "false")) {
            return Token.false;
        } else if (std.mem.eql(u8, identifier, "if")) {
            return Token.keyword_if;
        } else if (std.mem.eql(u8, identifier, "else")) {
            return Token.keyword_else;
        } else if (std.mem.eql(u8, identifier, "return")) {
            return Token.keyword_return;
        } else {
            return Token{ .identifier = identifier };
        }
    }
};

test "Token.equals" {
    const TestCase = struct {
        input_a: Token,
        input_b: Token,
        expected: bool,
    };

    const tests: []const TestCase = &.{
        .{
            .input_a = Token.illegal,
            .input_b = Token.illegal,
            .expected = true,
        },
        .{
            .input_a = Token.illegal,
            .input_b = Token.eof,
            .expected = false,
        },
        .{
            .input_a = Token{ .identifier = "abc" },
            .input_b = Token{ .identifier = "abc" },
            .expected = true,
        },
        .{
            .input_a = Token{ .identifier = "abc" },
            .input_b = Token{ .identifier = "def" },
            .expected = false,
        },
        .{
            .input_a = Token{ .integer = "123" },
            .input_b = Token{ .integer = "123" },
            .expected = true,
        },
        .{
            .input_a = Token{ .integer = "123" },
            .input_b = Token{ .integer = "456" },
            .expected = false,
        },
    };

    for (tests) |tt| {
        try std.testing.expectEqual(tt.expected, tt.input_a.equals(tt.input_b));
    }
}

test "Token.lookup_identifier" {
    const TestCase = struct {
        input: []const u8,
        expected: Token,
    };

    const tests: []const TestCase = &.{
        .{
            .input = "let",
            .expected = Token.let,
        },
        .{
            .input = "fn",
            .expected = Token.function,
        },
        .{
            .input = "true",
            .expected = Token.true,
        },
        .{
            .input = "false",
            .expected = Token.false,
        },
        .{
            .input = "if",
            .expected = Token.keyword_if,
        },
        .{
            .input = "else",
            .expected = Token.keyword_else,
        },
        .{
            .input = "return",
            .expected = Token.keyword_return,
        },
        .{
            .input = "abc",
            .expected = Token{ .identifier = "abc" },
        },
    };

    for (tests) |tt| {
        const actual = Token.lookup_identifier(tt.input);
        try std.testing.expect(tt.expected.equals(actual));
    }
}
