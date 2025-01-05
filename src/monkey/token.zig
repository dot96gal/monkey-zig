const TokenType = enum {
    illegal,
    eof,

    // Identifier + Literal
    identifier,
    integer,

    // Operator
    assign, // =
    plus, // +

    // Delimiters
    comma, // ,
    semicolon, // ;
    left_paren, // (
    right_paren, // )
    left_brace, // {
    right_brace, // }

    // Keyword
    function,
    let,
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
};
