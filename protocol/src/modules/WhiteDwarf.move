address  0xb987F1aB0D7879b2aB421b98f96eFb44 {
module WhiteDwarf {

    use 0x1::Token;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    struct WhiteDwarf<RCTokenType, RWToken> has key, store {
        recycling_target: Token::Token<RCTokenType>,
        reward_target: Token::Token<RWToken>,
        bonus: Quark::QUARK,
        start_at: u64,
        end_at: u64,
    }

}
}
    