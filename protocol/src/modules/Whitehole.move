address  0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Whitehole {
    use 0x1::Signer;
    use 0x1::Errors;
    use 0x1::Token;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    const NO_REWARD: u64 = 2002;
    const INVALID_INVITE_ADDRESS: u64 = 2003;

    public  fun has_candy(address: address): bool {
        candy_amount(address) >0
    }

    public fun candy_amount(address: address): u128 {
        let is_new_user = Badge::is_new_user(address);
        let amount = 0;
        if (is_new_user) {
            let (c_amount, _, _) = Quark::reward_balance();
            if (c_amount >0) {
                amount = amount + Quark::params();
            };
        };
        amount = amount + Badge::reward_amount(address);
        amount
    }


    public  fun claim_reward(account: &signer, invite_address: address) {
        assert(
            candy_amount(Signer::address_of(account)) >0,
            Errors::limit_exceeded(NO_REWARD)
        );
        if(Signer::address_of(account) != Token::token_address<Quark::QUARK>()){
            assert(
                invite_address!=Signer::address_of(account) ,
                Errors::invalid_argument(INVALID_INVITE_ADDRESS)
            );
        };


        let is_new_user = Badge::is_new_user(Signer::address_of(account));
        if (is_new_user) {
            Badge::initialize(account, Quark::get_candy());
            if (invite_address != Token::token_address<Quark::QUARK>()) {
                Badge::add_badge_exp(invite_address, 2, 1);
            }
        };
        Badge::claim_reward(account);
    }
}
}
    