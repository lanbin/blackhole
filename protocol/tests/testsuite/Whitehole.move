//! account: admin , 0xb987F1aB0D7879b2aB421b98f96eFb44
//! account: bob
//! sender: admin
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_initialize(sender: signer) {
        Quark::initialize(&sender);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Whitehole;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;
    use 0x1::Signer;

    fun has_candy(sender: signer) {
        let has_candy = Whitehole::has_candy(Signer::address_of(&sender));
        assert(has_candy, 1);
        let amount = Whitehole::candy_amount(Signer::address_of(&sender));
        assert(amount == Quark::params(), 4);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Whitehole;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;
    use 0x1::Signer;

    fun has_candy(sender: signer) {
        let has_candy = Whitehole::has_candy(Signer::address_of(&sender));
        assert(has_candy, 1);
        let amount = Whitehole::candy_amount(Signer::address_of(&sender));
        assert(amount == Quark::params(), 4);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
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
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Whitehole;
    use 0x1::Signer;

    fun after_claim_reward(sender: signer) {
        let amount = Whitehole::candy_amount(Signer::address_of(&sender));
        assert(amount == 0, 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Whitehole;

    fun after_claim_reward(sender: signer) {
        Whitehole::claim_reward(&sender,@0x1);
    }
}
// check: " Keep(ABORTED { code: 512520, "
