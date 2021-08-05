address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Blackhole {

    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::Errors;
    use 0x1::Token;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::CapHolder;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    const INSUFFICIENT_AVAILABLE_BALANCE: u64 = 3;

    const BURN_FEE: u128 = 1;
    //    use 0x1::Debug;

    public fun init(account: &signer) {
        let cap = CapHolder::hold(
            account,
            Account::extract_withdraw_capability(account)
        );
        CapHolder::destroy_get_capability(cap);
    }

    public fun burn_every_token<TokenType: store>(account: &signer, amount: u128, message: vector<u8>) {
        let balance = Account::balance<TokenType>(Signer::address_of(account));
        assert(balance >= amount, Errors::invalid_argument(INSUFFICIENT_AVAILABLE_BALANCE));
        let fee_amount = BURN_FEE * Token::scaling_factor<Quark::QUARK>();
        let quark_balance = Account::balance<Quark::QUARK>(Signer::address_of(account));
        assert(quark_balance >=  fee_amount , Errors::invalid_argument(INSUFFICIENT_AVAILABLE_BALANCE));
        if (!Account::exists_at(@0x666666)){ Account::create_account_with_address<TokenType>(@0x666666);};
        Account::pay_from_with_metadata<TokenType>(account,@0x666666, amount, message);

        let fee = Account::withdraw<Quark::QUARK>(account, fee_amount);
        Quark::add_to_treasury(fee);
    }
}
}
    