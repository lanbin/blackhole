//! account: admin , 0xb987F1aB0D7879b2aB421b98f96eFb44
//! account: bob
//! sender: admin
script {
    use 0x1::Token;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_initialize(sender: signer) {
        Quark::initialize(&sender);
        let total = Token::market_cap<Quark::QUARK>();
        let (candy_amount, reward_amount, bonus_amount) = Quark::reward_balance();
        assert(total * 5 / 100 == candy_amount, 1);
        assert(total * 5 / 100 == reward_amount, 1);
        assert(total * 0 / 100 == bonus_amount, 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    use 0x1::Account;

    fun test_initialize(sender: signer) {
        let token = Quark::get_candy();
        Account::deposit_to_self(&sender, token);
    }
}
// check: "Keep(EXECUTED)"