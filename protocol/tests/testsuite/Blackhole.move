//! account: bob,20000000000000 0x1::STC::STC
//! account: alice,20000000000000 0x1::STC::STC
//! account: admin , 0xb987F1aB0D7879b2aB421b98f96eFb44
//! sender: admin
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_initialize(sender: signer) {
        Quark::initialize(&sender);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Whitehole;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;
    use 0x1::Account;
    use 0x1::Signer;

    fun claim_reward(sender: signer) {
        let amount = Whitehole::candy_amount(Signer::address_of(&sender));
        Whitehole::claim_reward(&sender,@0x1);
        let balance = Account::balance<Quark::QUARK>(Signer::address_of(&sender));
        assert(balance == amount, 1);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: alice
script {
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::STC;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Blackhole;
    fun test(sender: signer) {
        assert(!Account::exists_at(@0x666666), 1);
        let message = b"every thing....";
        Blackhole::burn_every_token<STC::STC>(&sender, 10000000000000, message);
        let balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        assert(balance == 10000000000000, 2);
        assert(Account::exists_at(@0x666666), 3);
        let balance = Account::balance<STC::STC>(@0x666666);
        assert(balance == 10000000000000, 4);
        0x1::Debug::print(&b"abcdd");
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::STC;

    fun test(sender: signer) {
        let balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        assert(balance == 20000000000000, 1);
        let tokens = Account::withdraw<STC::STC>(&sender, 1);
        STC::burn(tokens);
        let balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        assert(balance == 20000000000000 - 1, 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Blackhole;

    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::STC;
    use 0x1::Token;

    fun test(sender: signer) {
        let balance = Account::balance<STC::STC>(Signer::address_of(&sender));
        assert(balance == 20000000000000 - 1, 1);
        Blackhole::init(&sender);
        let tokens = Account::withdraw<STC::STC>(&sender, 1);
        Token::burn(&sender, tokens);
    }
}
// check: " Keep(ABORTED { code: 25857, "


